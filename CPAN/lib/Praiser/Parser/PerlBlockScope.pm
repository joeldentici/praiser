#!/usr/bin/perl

package Praiser::Parser::PerlBlockScope;
use base qw(Praiser::Parser::PerlScope);

sub __init {
	my ($self) = @_;

	$self->SUPER::__init();

	$self->{nocount} = 0;
	$self->{firstchar} = 1;
	$self->{specialblock} = 1;
	$self->{done} = 0;
}

sub processToken {
	my ($self, $token) = @_;

	$self->processString($token);

	if ($token eq '{' && $self->{stringtype} eq 'none') {
		$self->openThing('BRACE');
		$self->addBrace($token);
	}
	elsif ($token eq '}' && $self->{stringtype} eq 'none') {
		$self->closeThing('BRACE');
		$self->addBrace($token);
	}
	elsif ($token eq '\\' && $self->{stringtype} ne 'none') {
		$self->addOutput('\\' . $self->{parser}->nextToken);
	}
	else {
		$self->countToken($token);
		$self->addOutput($token);
	}

	$self->{firstchar} = 0;
}

sub countToken {
	my ($self, $token) = @_;

	if ($token eq '('  && $self->{stringtype} eq 'none') {
		$self->openThing('PAREN');
	}

	if ($token eq ')'  && $self->{stringtype} eq 'none') {
		$self->closeThing('PAREN');
	}
}

sub firstPAREN {
	my ($self) = @_;

	$self->{nocount} = 1;
}

sub lastPAREN {
	my ($self) = @_;

	$self->{nocount} = 0;
}

sub firstBRACE {
	my ($self) = @_;

	if ($self->{firstchar}) {
		$self->{specialblock} = 0;
	}
}

sub lastBRACE {
	my ($self) = @_;

	if (!$self->{nocount}) {
		$self->{parser}->exitScope();
		$self->{done} = 1;
	}
}

sub addBrace {
	my ($self, $token) = @_;

	if ($self->{specialblock}) {
		$self->addOutput($token);
	}
	elsif (!$self->{firstchar} && !$self->{done}) {
		$self->addOutput($token);
	}
}

sub generateOutput {
	my ($self, $output) = @_;

	if ($output =~ /.*\s$/) {
		return $output;
	}

	return $output . "\n";
}

sub addOutput {
	my ($self, $token) = @_;

	if ($self->seeTag && $self->{stringtype} eq 'none') {
		$self->SUPER::addOutput($token);
		$self->{parser}->enterScope('HTMLTagScope');
	}
	else {
		$self->SUPER::addOutput($token);
	}
}

1;