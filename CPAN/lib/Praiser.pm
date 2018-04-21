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

1;