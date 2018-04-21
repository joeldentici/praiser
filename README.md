# Praiser
Praiser is a templating engine for Perl designed to mimic the awesomeness of ASP.NET Razor. Like Razor, Praiser allows powerful templating with minimal syntactic noise.

Praiser gives you the full power of Perl inside your templates. It's minimal design is cleaner than similar projects like Template::ToolKit and Mason. It is also much less verbose to use.

## Example
Here is a simple template that greets you with the current date:

```perl
@{
	use POSIX qw(strftime);
	my $date = strftime "%m/%d/%Y", localtime;
}

@{ my $greeting = "Welcome to Praiser!"}
@{
	my $message = $greeting . ' ' . "Today is $date";
}
<p>@$greeting</p>
```

You can put this in a file called `greeting.plhtml` and process it with this code:

```perl
package main;

use Praiser;

my $praiser = Praiser->new({
	directory => ''
});

$praiser->toSub('greeting.plhtml', sub { print @_ });

print "\n";

```

This will print the following (with the current date, not 04/20/2018):

```html
<p>Welcome to Praiser! Today is 04/20/2018</p>
```

## Praiser Template Usage

## API
TODO: Add API reference information

## Progress
This project is a work in progress. There are some things I still want to do:

- [ ] Integrate Perl compiler tools (B::)
- [ ] Better error messages