package TinyEyeSearch;

use strict;
use warnings FATAL => 'all';

use constant {
    TINYEYE_BASE_URL    => 'http://api.tineye.com/rest/search/',
    TINYEYE_PRIVATE_KEY => '6mm60lsCNIB,FwOWjJqA80QZHh9BMwc-ber4u=t^',
    TINYEYE_PUBLIC_KEY  => 'LCkn,2K7osVwkX95K4Oy',
    MY_PRIVATE_KEY      => '',
    MY_PUBLIC_KEY       => '',
};

use Digest::HMAC_SHA1 qw{ hmac_sha1_hex };
use Data::UUID;
use URI::Escape;
use LWP::UserAgent;
use JSON;

sub search {

    my ($img_url, $test, $offset, $limit) = @_;

    my $ua   = LWP::UserAgent->new;
    my $url  = url($img_url, $test, $offset, $limit);

    print "Reqest URL: $url\n";

    my $resp = $ua->get($url, $test, $offset, $limit);

    my $content = $resp->is_success ? $resp->decoded_content : 'Request failed with ' . $resp->status_line;

    return {
        status => $resp->is_success,
        content => $resp->is_success ? decode_json($content) : 'Request failed with: ' . $resp->status_line,
    };
}

sub url {

    my ($img_url, $test, $offset, $limit) = @_;

    $test   //= 1;
    $offset //= 0;
    $limit  //= 100;

    my $ug     = Data::UUID->new;
    my $uuid   = $ug->create;
    my $nonce  = ($ug->to_string($uuid) =~ s/\-//gr);
    my $tstamp = time();

    my $uri = join('&', (
        'image_url='  . uri_escape($img_url),
        'limit='  . $limit,
        'offset=' . $offset,
    ));

    my ($private_key, $public_key) = $test ? (
        TINYEYE_PRIVATE_KEY, TINYEYE_PUBLIC_KEY ) : (
            MY_PRIVATE_KEY, MY_PUBLIC_KEY );


    my $str = $private_key .
        'GET' .
        '' . # Empty string for GET
        '' . # Empty string for GET
        $tstamp .
        $nonce .
        TINYEYE_BASE_URL .
        $uri;

    my $sig = hmac_sha1_hex($str, $private_key);

    return TINYEYE_BASE_URL . '?' . join('&', (
        'api_key=' . uri_escape($public_key),
        'date=' . $tstamp,
        'nonce=' . $nonce,
        'api_sig=' . $sig,
        $uri,
    ));
}

1;
