package Cookbook::Japanese;

use Cookbook::UTF8Request;

use strict;

sub handler {

  my $r = Cookbook::UTF8Request->new(shift, 'iso-2022-jp');

  $r->send_http_header('text/html; charset=iso-2022-jp');

  my $yes = "\x{3059}\x{308B}";
  my $no  = "\x{3057}\x{306A}\x{3044}";

  my ($name) = $r->param('name');

  $r->print(<<HERE);
    <html>
      <body>
        Name is '$name'<br>
        <form method="POST">
          <input type="text" name="name"><input type="submit">
        </form>
        Yes ($yes), No ($no)
      </body>
    </html>
HERE
}
1;
