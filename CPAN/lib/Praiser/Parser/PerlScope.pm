#!/usr/bin/perl

package Praiser::Parser::PerlScope;

use base qw(Praiser::Parser::Scope);

sub __init {
	my ($self) = @_;

	$self->{things} = {};
	$self->{stringtype} = 'none';
}

sub processString {
	my ($self, $token) = @_;

	if ($token eq '"' && $self->{stringtype} eq 'none') {
		$self->{stringtype} = 'double';
	}
	elsif ($token eq '"' && $self->{stringtype} eq 'double') {
		$self->{stringtype} = 'none';
	}
	elsif ($token eq "'" && $self->{stringtype} eq 'none') {
		$self->{stringtype} = 'single';
	}
	elsif ($token eq "'" && $self->{stringtype} eq 'single') {
		$self->{stringtype} = 'none';
	}
}

sub openThing {
	my ($self, $thing) = @_;

	$self->{things}->{$thing} = $self->{things}->{$thing} || 0;

	$self->{things}->{$thing}++;

	if ($self->{things}->{$thing} == 1 && $self->can('first' . $thing)) {
		my $method = 'first' . $thing;

		$self->$method;
	}
}

sub closeThing {
	my ($self, $thing) = @_;

	$self->{things}->{$thing} = $self->{things}->{$thing} || 0;

	if ($self->{things}->{$thing} == 0) {
		die "Unmatched $thing";
	}

	$self->{things}->{$thing}--;

	if ($self->{things}->{$thing} == 0 && $self->can('last' . $thing)) {
		my $method = 'last' . $thing;

		$self->$method;
	}
}

1;