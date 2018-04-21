#!/usr/bin/perl

package Praiser::Parser::HTMLFileScope;

use base qw(Praiser::Parser::HTMLScope);

sub additionalProcessing {
	my ($self, $token) = @_;

	$self->addOutput($token);

	if ($self->seeTag) {
		$self->{parser}->enterScope('HTMLTagScope');
	}
}

sub generateSub {
	my ($self) = @_;

return q/sub {
	my ($output, $include, $args) = @_;

/. $self->tabCode($self->generate) . q/
}
/;

}

sub tabCode {
	my ($self, $code) = @_;

	my @lines = split /\n/, $code;
	@lines = map {"\t$_"} @lines;

	return join "\n", @lines;
}

sub additionalOutput {
	my ($self, $output) = @_;

	return "\n";
}

1;