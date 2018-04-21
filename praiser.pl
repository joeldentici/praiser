#!/usr/bin/perl

# the praiser module will eventually be deployed to CPAN
use lib 'CPAN/lib';

use Praiser;

my $praiser = Praiser->new({
	directory => 'examples'
});

if ($ARGV[0]) {
	$praiser->toSub($ARGV[0] . '.plhtml', sub { print @_ }, {
		cmd => \@ARGV
	});

	print "\n";
}
else {
	$praiser->toSub('test.plhtml', sub { print @_ }, {
		test => 'hi',
		name => 'foo',
		host => 'google.com',
		times => 10
	});

	print "\n";
}