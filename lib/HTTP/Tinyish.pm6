use v6;
unit class HTTP::Tinyish;
use HTTP::Tinyish::Curl;

method new(*%opt) {
    HTTP::Tinyish::Curl.new(|%opt);
}

=begin pod

=head1 NAME

HTTP::Tinyish - perl6 port of HTTP::Tinyish

=head1 SYNOPSIS

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

=head1 DESCRIPTION

HTTP::Tinyish is perl6 port of L<https://github.com/miyagawa/HTTP-Tinyish>.
Currently only support curl.

=head2 Str VS Buf

Perl6 distinguishes Str from Buf.
HTTP::Tinyish handles data as Str by default
(that is, encode/decode utf-8 if needed by default).
If you want to handle data as Buf, please follow the instruction below.

If you want to send Buf content, just specify Buf in content:

   my $binary-data = "file.bin".IO.slurp(:bin);
   $http.post:
      "http://example.com/post",
      content => $binary-data,
   ;

If you want to recieve http content as Buf, then call request/get/post/... method with
C<< bin => True >>:

   my %res = $http.get("http://example.com/image.png", bin => True);
   does-ok %res<content>, Buf; # pass

And decode C<< %res<content> >> by yourself if you want.

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Original perl5 HTTP::Tinyish COPYRIGHT and LICENSE:

  COPYRIGHT
  Tatsuhiko Miyagawa, 2015-

  LICENSE
  This module is licensed under the same terms as Perl itself.

=end pod
