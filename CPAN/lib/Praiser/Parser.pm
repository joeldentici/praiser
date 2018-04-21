#!/usr/bin/perl

package Praiser::Parser;
use Module::Load qw();

sub new {
	my ($class) = @_;

	return bless {}, $class;
}

sub parse {
	my ($self, $input) = @_;

	$self->initialize($input);

	my $token;
	while (defined($token = $self->nextToken)) {
		$self->currentScope->processToken($token);
	}

	return $self->{stack}->[0];
}

sub initialize {
	my ($self, $input) = @_;

	my @input = split //, $input;

	$self->{input} = \@input;
	$self->{stack} = [];
	$self->{position} = 0;

	$self->enterScope('HTMLFileScope');
}

sub enterScope {
	my ($self, $scopeName) = @_;

	my $module = 'Praiser::Parser::' . $scopeName;
	Module::Load::load($module);

	my $scope = $module->new($self);

	my $current = $self->currentScope;
	if ($current) {
		$current->addScope($scope);
	}

	push @{$self->{stack}}, $scope;
}

sub exitScope {
	my ($self) = @_;

	if ($self->currentScope) {
		pop @{$self->{stack}};
	}
}

sub currentScope {
	my ($self) = @_;

	my $num = scalar @{$self->{stack}};

	return $self->{stack}->[$num - 1];
}

sub nextToken {
	my ($self) = @_;

	return $self->{input}->[$self->{position}++];
}

sub lookahead {
	my ($self, $amount) = @_;

	$amount = ($amount || 1) - 1;

	return $self->{input}->[$self->{position} + $amount];
}

1;