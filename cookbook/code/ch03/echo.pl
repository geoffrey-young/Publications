#!/usr/bin/perl -w

use strict;

my $r = shift;

# send our basic headers..
$r->send_http_header('text/plain');

# read things you would normally get from CGI
print " REQUEST_METHOD is: ", $r->method,          "\n";
print "    REQUEST_URI is: ", $r->uri,             "\n";
print "SERVER_PROTOCOL is: ", $r->protocol,        "\n";
print "      PATH_INFO is: ", $r->path_info,       "\n";
print "   QUERY_STRING is: ", scalar $r->args,     "\n";
print "SCRIPT_FILENAME is: ", $r->filename,        "\n";
print "    SERVER_NAME is: ", $r->hostname,        "\n";
