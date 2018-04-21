#!/usr/bin/perl


package Praiser::Parser::HTMLTagScope;

use base qw(Praiser::Parser::HTMLScope);

sub __init {
	my ($self) = @_;

	$self->SUPER::__init();

	$self->{tagcount} = 0;
	$self->{done} = 0;
}

sub additionalProcessing {
	my ($self, $token) = @_;

	if ($self->isCloseTag($token)) {
		$self->handleCloseTag($token);
	}
	elsif ($self->isOpenTag($token)) {
		$self->handleOpenTag($token);
	}
	elsif ($token eq '>' && $self->{done}) {
		$self->addOutput($token);
		$self->{parser}->exitScope();
	}
	else {
		$self->addOutput($token);
	}
}

sub handleOpenTag {
	my ($self, $token) = @_;

	$self->addOutput($token);

	$self->{tagcount}++;
}

sub handleCloseTag {
	my ($self, $token) = @_;

	$self->{tagcount}--;

	$self->addOutput($token);

	if ($self->{tagcount} == 0) {
		$self->{done} = 1;
	}
}

sub addCloseTag {
	my ($self, $token) = @_;

	$self->addOutput('<');

	while ($self->{parser}->{lookahead} ne '>') {
		$self->addOutput($self->{parser}->nextToken);
	}

	$self->addOutput($self->{parser}->nextToken);
}

sub isOpenTag {
	my ($self, $token) = @_;

	return $token eq '<' && $self->{parser}->lookahead =~ /[a-zA-Z]/;
}

sub isCloseTag {
	my ($self, $token) = @_;

	return $token eq '<' && $self->{parser}->lookahead eq '/';
}

sub additionalOutput {
	my ($self, $output) = @_;

	return "\n";
}

1;