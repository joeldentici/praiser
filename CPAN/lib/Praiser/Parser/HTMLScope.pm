#!/usr/bin/perl

package Praiser::Parser::HTMLScope;

use base qw(Praiser::Parser::Scope);

use Data::Dumper;

sub __init {
	my ($self) = @_;

	$self->SUPER::__init();

	$self->{expressions} = [];
}

sub processToken {
	my ($self, $token) = @_;

	if ($token eq '@' && $self->{parser}->lookahead eq '@') {
		$self->addOutput('@');
	}
	elsif ($token eq '@' && $self->seeBlock) {
		$self->{parser}->enterScope('PerlBlockScope');
	}
	elsif ($token eq '@' && $self->{parser}->lookahead =~ /\s/) {
		$self->addOutput('@');
	}
	elsif ($token eq '@') {
		$self->{parser}->enterScope('PerlExpressionScope');
	}
	else {
		$self->additionalProcessing($token);
	}
}

sub seeBlock {
	my ($self, $token) = @_;

	my $seeBrace = $self->{parser}->lookahead eq '{';

	return $seeBrace || $self->isSomeCode('for', 'sub', 'while', 'if', 'elsif', 'else');
}

sub isSomeCode {
	my ($self, @types) = @_;

	for my $t (@types) {
		if ($self->isCode($t)) {
			return 1;
		}
	}

	return 0;
}

sub isCode {
	my ($self, $text) = @_;

	my @text = split //, $text;
	my $i = 1;

	for my $t (@text) {
		return 0 if $self->{parser}->lookahead($i++) ne $t;
	}

	return $self->{parser}->lookahead($i) eq ' ';
}

sub generateOutput {
	my ($self, $output) = @_;

	if (length $output && $output =~ /[^\s]/) {
		return '$output->(' . $self->quote($output) . ');' . $self->additionalOutput($output);
	}
	else {
		return '';
	}

}

sub quote {
	my ($self, $text) = @_;

	$Data::Dumper::Useqq = 1;
	$Data::Dumper::Terse = 1;

	my $text = Dumper($text);

	return substr($text, 0, length($text) - 1);
}

1;