package Cookbook::PrintUploads;

use Apache::Constants qw(OK);
use Apache::Request;
use Apache::Util qw(escape_html);

use strict;

sub handler {

  # Standard stuff, with added options...
  my $r = Apache::Request->new(shift,
                               POST_MAX => 10 * 1024 * 1024, # in bytes, so 10M
                               DISABLE_UPLOADS => 0);

  my $status = $r->parse();

  # Return an error if we have problems.
  return $status unless $status == OK;

  $r->send_http_header('text/html');

  $r->print("<html><body>\n");
  $r->print("<h1>Upload files</h1>");

  # Iterate through each uploaded file.
  foreach my $upload ($r->upload) {
    my $filename    = $upload->filename;
    my $filehandle  = $upload->fh;
    my $size        = $upload->size;

    $r->print("You sent me a file named $filename, $size bytes<br>");
    $r->print("The first line of the file is: <br>");
    my $line = <$filehandle>;
    $r->print(escape_html($line), "<br>");
  }
  $r->print("Done......<br>");

  # Output a simple form.
  $r->print(<<EOF);
  <form enctype="multipart/form-data" name="files" action="/upload" method="POST">
    File 1 <input type="file" name="file1"><br>
    File 2 <input type="file" name="file2"><br>
    File 3 <input type="file" name="file3"><br><br>
    <input type="submit" name="submit" value="Upload these files">
  </form>
 </body></html>
EOF

  return OK;
};
1;
