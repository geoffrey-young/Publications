package Cookbook::ShipXML;

use Apache::Constants qw(OK);

use XML::Generator;

use strict;

sub handler {

  my $r = shift;

  my $x = XML::Generator->new(escape      => 'always',
                              pretty      => 2,
                              conformance => 'strict');

  my $captains = $x->captainlist(
          map {$x->captain($_)} qw(Ahab Kirk Columbus)
     );

  print $r->send_http_header('text/xml');

  print $x->xml(
          $x->shipdata(
            $captains,
            $x->shiplist(
               $x->ship({type => 'riverboat'},
                        $x->name('Belle of the South'),
                        $x->registry('USA')),
               $x->ship({type => 'oil_tanker'},
                        $x->name('Valdez'),
                        $x->registry('Liberia'))
            )
          )
        );

  return OK;
}
1;
