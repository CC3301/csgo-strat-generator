package Util::Encoder;

use strict;
use warnings;

## Code taken from: https://metacpan.org/pod/MIME::Base32


sub encode_base32hex {
    my $arg = shift;
    return '' unless defined($arg);    # mimic MIME::Base64

    $arg = unpack('B*', $arg);
    $arg =~ s/(.....)/000$1/g;
    my $l = length($arg);
    if ($l & 7) {
        my $e = substr($arg, $l & ~7);
        $arg = substr($arg, 0, $l & ~7);
        $arg .= "000$e" . '0' x (5 - length $e);
    }
    $arg = pack('B*', $arg);
    $arg =~ tr|\0-\37|0-9A-V|;
    return $arg;
}

sub decode_base32hex {
    my $arg = uc(shift || '');    # mimic MIME::Base64

    $arg =~ tr|0-9A-V|\0-\37|;
    $arg = unpack('B*', $arg);
    $arg =~ s/000(.....)/$1/g;
    my $l = length($arg);
    $arg = substr($arg, 0, $l & ~7) if $l & 7;
    $arg = pack('B*', $arg);
    return $arg;
}
1;
