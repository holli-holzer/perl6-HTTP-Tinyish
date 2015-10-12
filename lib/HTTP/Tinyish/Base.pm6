use v6;
unit class HTTP::Tinyish::Base;

method get($url,    *%opts) { self.request('GET',     $url, |%opts) }
method head($url,   *%opts) { self.request('HEAD',    $url, |%opts) }
method put($url,    *%opts) { self.request('PUT',     $url, |%opts) }
method post($url,   *%opts) { self.request('POST',    $url, |%opts) }
method delete($url, *%opts) { self.request('DELETE',  $url, |%opts) }


method parse-http-header($header is copy, %res) {
    # it might have multiple headers in it because of redirects
    $header ~~ s/.*^^(HTTP\/\d\.\d )/$/[0]/;

    # grab the first chunk until the line break
    if $header ~~ /^(.*?\x0d?\x0a\x0d?\x0a)/ {
        $header = $0;
    }

    # parse into lines
    my @header = split /\x0d?\x0a/, $header;
    my $status_line = shift @header;

    # join folded lines
    my @out;
    for @header {
        if /^[' '\t]+/ {
            return unless @out;
            @out[*-1] ~= $_;
        } else {
            push @out, $_;
        }
    }

    my ($proto, $status, $reason) = split /' '/, $status_line, 3;
    return unless $proto and $proto ~~ /:i ^ HTTP \/ \d+ \. \d+ $/;

    %res<status> = $status.Int;
    %res<reason> = $reason;
    %res<success> = so $status ~~ /^[2|304]/;
    %res<headers> //= {};

    # import headers
    my $token = rx:P5/[^][\x00-\x1f\x7f()<>@,;:\\"\/?={} \t]+/; # 
    my $k;
    for @out <-> $header {
        if $header ~~ s/^($token) \: ' '?// {
            $k = lc $/[0];
        } elsif $header ~~ /^\s+/ {
            # multiline header
        } else {
            return;
        }

        if %res<headers>{$k}:exists {
            %res<headers>{$k} = [%res<headers>{$k}] unless %res<headers>{$k} ~~ Positional;
            %res<headers>{$k}.push($header);
        } else {
            %res<headers>{$k} = $header;
        }
    }
    return True;
}

method internal-error($url, $message) {
    my $length = $message ~~ Buf ?? $message.elems !! $message.chars;
    # XXX content-type?
    my %res =
        content => $message,
        headers => { "content-length" => $length, "content-type" => "text/plain" },
        reason  => "Internal Exception",
        status  => 599,
        success => False,
        url     => $url,
    ;
    |%res;
}
