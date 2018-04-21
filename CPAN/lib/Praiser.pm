#!/usr/bin/perl

package Praiser;

use Praiser::Parser;

sub new {
	my ($class, $options) = @_;

	return bless {
		directory => $options->{directory},
		cache => {},
		parser => Praiser::Parser->new
	}, $class;
}

sub toBuffer {
	my ($self, $templateName, $buffer, $args) = @_;

	$self->toSub($templateName, sub {
		my ($text) = @_;

		$$buffer .= $text;
	}, $args);
}

sub toWriter {
	my ($self, $templateName, $writer, $args) = @_;

	$self->toSub($templateName, sub { $writer->write($_[0]) }, $args);
}

sub toSub {
	my ($self, $templateName, $output, $args) = @_;

	my $templateProcessor = $self->resolve($templateName);

	my $include = sub {
		my ($template) = @_;

		$self->toSub($template, $output, $args);

		return ''; #might be called in expression context
	};

	$templateProcessor->($output, $include, $args);
}

sub resolve {
	my ($self, $templateName) = @_;

	unless ($self->{cache}->{$templateName}) {
		my $templateText = $self->loadFile($templateName);

		my $templateFile = $self->{parser}->parse($templateText);

		my $src = $templateFile->generateSub;

		$self->{cache}->{$templateName} = eval($src);
	}

	return $self->{cache}->{$templateName};
}

sub loadFile {
	my ($self, $templateName) = @_;

	my $filePath = $self->{directory} . '/' . $templateName;

	my $data;
	{
		local *FH;
		open( FH, $filePath) or die("Error: $!\n");
		sysread FH, $data, -s FH;
		close FH;
	}

	return $data;
}

=head1 NAME

Praiser - Praiser template engine for Perl

=head1 SYNOPSIS

	use Praiser;
	my $praiser = Praiser->new({
		directory => '/path/to/templates'
	});

	$praiser->toSub('template.plhtml', sub { print @_ });

	$praiser->toSub('template.plhtml', sub { print @_ }, {arg1 => 'val'});

	my $buffer;
	$praiser->toBuffer('template.plhtml', \$buffer, {arg1 => 'val'});

	my $writer; # some object with write($x : string) : () method
	$praiser->toBuffer('template.plhtml', $writer, {arg1 => 'val'});

=head1 DESCRIPTION

Praiser is a templating engine for Perl designed to mimic the awesomeness of ASP.NET Razor.
Like Razor, Praiser allows powerful templating with minimal syntactic noise.

Praiser gives you the full power of Perl inside your templates.
It's minimal design is cleaner than similar projects like Template::ToolKit and Mason.
It is also much less verbose to use.

=head2 Templates

Praiser templates allow you to easily transition between Perl and HTML. Here is an example template that
shows a greeting message with the current date:

	@{
		use POSIX qw(strftime);
		my $date = strftime "%m/%d/%Y", localtime;
	}

	@{ my $greeting = "Welcome to Praiser!"; }
	@{
		my $message = $greeting . ' ' . "Today is $date";
	}
	<p>@$message</p>

When Praiser processes this template, it produces:

	<p>Welcome to Praiser! Today is [MM/DD/YY]<p>

You can also pass arguments to templates. Here is how you use arguments:

	@{
		my $name = $args->{name};
	}

	<p>Hello @$name</p>

If you are creating complicated templates, you will probably want to break them up.
You can include other templates anywhere inside a template:

	@$include->('header.plhtml')
	<p>Page body</p>
	@$include->('footer.plhtml')

You may have noticed that our Perl code can be delimited in multiple ways.

=head3 Perl Expressions

Praiser can automatically output the results of Perl expressions. To do this, you delimit a Perl expression:

	@PerlExpression

The expression automatically ends at the first whitespace or beginning of an HTML tag. So:

	@$x + $y

will display:

	2 + $y

if

	$x = 2
	$y = 2

If you wrote this, you probably intended to output the result of:

	$x + $y

You can do this by wrapping the entire expression in parentheses:

	@($x + $y)

=head3 Perl Blocks

Praiser can also evaluate entire blocks of Perl code and output HTML that is embedded inside of them.

There are 2 styles of blocks. The first is a normal block:

	@{
		Perl Statements
	}

The other style is a special block for common syntactic elements. Here is an if-statement:

	@if ($x > 5) {
		<p>$x is greater than 5!</p>
	} @else {
		<p>$x is less than or equal to 5!</p>
	}

The supported special blocks are:

	@while () { }

	@for [optional binding] () { }

	@sub [optional name] { }

	@if () { }

	@elsif () { }

	@else () { }

The special blocks are provided to reduce the verbosity of templates.

=head2 Methods


=head1 CAVEATS

This is not actually parsing Perl or HTML. It detects whether tokens coming up belong to Perl (delimited by @)
or to HTML (delimited by <xml> tags).

Despite this, templates have a very neat and easy to follow lexical structure. Perl embedded inside HTML
does what you think it will and HTML embedded inside Perl does what you think it will.

Hopefully the fact that this is not actually parsing against a grammar doesn't make it brittle.

=head1 LICENSE

MIT License

Copyright (c) 2018 Joel Dentici

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut


1;