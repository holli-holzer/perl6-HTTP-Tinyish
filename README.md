[![Build Status](https://travis-ci.org/skaji/perl6-HTTP-Tinyish.svg?branch=master)](https://travis-ci.org/skaji/perl6-HTTP-Tinyish)

NAME
====

HTTP::Tinyish - perl6 port of HTTP::Tinyish

SYNOPSIS
========

Synchronous way:

```perl6
my $http = HTTP::Tinyish.new(agent => "Mozilla/4.0");

my %res = $http.get("http://www.cpan.org/");
warn %res<status>;

$http.post:
  "http://example.com/post",
  headers => { "Content-Type" => "application/x-www-form-urlencoded" },
  content => "foo=bar&baz=quux",
;

$http.mirror:
  "http://www.cpan.org/modules/02packages.details.txt.gz",
  "./02packages.details.txt.gz",
;
```

Asynchronous way:

```perl6
my $http = HTTP::Tinyish.new(:async);

my @url = <
  http://perl6.org/
  https://doc.perl6.org/
  http://design.perl6.org/
>;

my @promise = @url.map: -> $url {
  $http.get($url).then: -> $promise {
    my %res = $promise.result;
    say "Done %res<status> %res<url>";
    %res;
  };
};

my @res = await @promise;
```

DESCRIPTION
===========

HTTP::Tinyish is perl6 port of [https://github.com/miyagawa/HTTP-Tinyish](https://github.com/miyagawa/HTTP-Tinyish). Currently only support curl.

Str VS Buf
----------

Perl6 distinguishes Str from Buf. HTTP::Tinyish handles data as Str by default (that is, encode/decode utf-8 if needed by default). If you want to handle data as Buf, please follow the instruction below.

If you want to send Buf content, just specify Buf in content:

```perl6
my $binary-data = "file.bin".IO.slurp(:bin);
$http.post:
  "http://example.com/post",
  content => $binary-data,
;
```

If you want to recieve http content as Buf, then call request/get/post/... method with `bin => True `:

```perl6
my %res = $http.get("http://example.com/image.png", bin => True);
does-ok %res<content>, Buf; # pass
```

And decode `%res<content> ` by yourself if you want.

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Original perl5 HTTP::Tinyish COPYRIGHT and LICENSE:

    COPYRIGHT
    Tatsuhiko Miyagawa, 2015-

    LICENSE
    This module is licensed under the same terms as Perl itself.

