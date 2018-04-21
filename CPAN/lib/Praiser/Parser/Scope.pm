#!/usr/bin/perl

package Praiser::Parser::Scope;

sub new {
	my ($class, $parser, @args) = @_;

	my $self = bless {
		parser => $parser,
		outputs => [''],
		children => [],
	}, $class;

	$self->__init(@args);

	return $self;
}

sub __init {

}

sub addScope {
	my ($self, $child) = @_;

	push @{$self->{children}}, $child;
	push @{$self->{outputs}}, '';
}

sub addOutput {
	my ($self, $output) = @_;

	my $num = scalar @{$self->{outputs}};
	$self->{outputs}->[$num - 1] .= $output;
}

sub generate {
	my ($self) = @_;

	my $code = '';

	my $i = 0;
	for my $output (@{$self->{outputs}}) {
		$code .= $self->generateOutput($output);
		if ($self->{children}->[$i]) {
			$code .= $self->{children}->[$i]->generate;
		}

		$i++;
	}

	if ($self->{children}->[$i]) {
		$code .= $self->{children}->[$i]->generate;
	}

	return $self->generateBounds($code);
}

sub generateOutput {
	my ($self, $output) = @_;

	die "Call to virtual method Praiser::Parser::Generator->generateOutput";
}

sub generateBounds {
	my ($self, $output) = @_;

	return $output;
}

sub seeTag {
	my ($self, $token) = @_;

	return $self->{parser}->lookahead(1) eq '<' && $self->{parser}->lookahead(2) =~ /[a-zA-Z]/;
}

sub seeAnyTag {
	my ($self, $token) = @_;


	return $self->{parser}->lookahead(1) eq '<' 
		&& ($self->{parser}->lookahead(2) =~ /[a-zA-Z\/]/);
}

1;