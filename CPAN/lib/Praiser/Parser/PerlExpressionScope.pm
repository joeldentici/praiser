#!/usr/bin/perl

package Praiser::Parser::PerlExpressionScope;
use base qw(Praiser::Parser::PerlScope);

sub __init {
	my ($self) = @_;

	$self->SUPER::__init();

	$self->{stringtype} = 'none';
	$self->{firstchar} = 1;
	$self->{freeexpression} = 1;
}

sub processToken {
	my ($self, $token) = @_;

	$self->processString($token);

	if ($self->{parser}->lookahead =~ /\s/ 
		&& $self->{freeexpression} 
		&& $self->{stringtype} eq 'none') {

		$self->addOutput($token);
		$self->{parser}->exitScope();
	}
	elsif ($self->seeAnyTag 
		&& $self->{stringtype} ne 'none'
		&& !$self->{freeexpression}) {

		die "HTML tag cannot appear inside of an explicit Perl expression!";
	}
	elsif ($self->seeAnyTag
		&& $self->{stringtype} eq 'none'
		&& $self->{freeexpression}) {

		$self->addOutput($token);
		$self->{parser}->exitScope();
	}
	else {
		$self->countToken($token);
		$self->addOutput($token);
	}

	$self->{firstchar} = 0;
}

sub countToken {
	my ($self, $token) = @_;

	if ($token eq '(' && $self->{stringtype} eq 'none') {
		$self->openThing('PAREN');
	}

	if ($token eq ')' && $self->{stringtype} eq 'none') {
		$self->closeThing('PAREN');
	}
}

sub firstPAREN {
	my ($self) = @_;

	if ($self->{firstchar}) {
		$self->{freeexpression} = 0;
	}
}

sub lastPAREN {
	my ($self) = @_;

	if (!$self->{freeexpression}) {
		$self->{parser}->exitScope();
	}
}

sub generateOutput {
	my ($self, $output) = @_;

	return '$output->(' . $output . ');' . "\n";
}

1;