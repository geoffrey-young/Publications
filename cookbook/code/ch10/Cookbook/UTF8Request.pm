package Cookbook::UTF8Request;

use Cookbook::TransformRequest ();
use Text::Iconv ();

use strict;

sub new {

  my($class, $r, $charset) = @_;

  my $to_unicode = Text::Iconv->new($charset, 'UTF-8');
  my $from_unicode = Text::Iconv->new('UTF-8', $charset);

  my $input_transform  =  sub {$to_unicode->convert(@_)};
  my $output_transform =  sub {$from_unicode->convert(@_)};

  return Cookbook::TransformRequest->new($r, 
                                         $input_transform,
                                         $output_transform);
}
1;
