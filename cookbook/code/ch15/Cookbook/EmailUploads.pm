package Cookbook::EmailUploads;

use Apache::Constants qw(OK SERVER_ERROR);
use Apache::Request;

use Cookbook::Mail qw(send_mail);

use strict;

sub handler {

  my $r = Apache::Request->new(shift, DISABLE_UPLOADS => 0);

  # If sendmail isn't present, specify an SMTP host
  # here and below...
  # my $smtp_host = 'my.smtp.host';

  my $upload = $r->upload;
  my %attachment;

  if ($upload) {
    # Send the email.
    my ($name) = $upload->filename =~ m!([^/\\]*$)!;

    %attachment = (file => $upload->tempname,
                   name => $name);

    send_mail($r, From => $r->server->server_admin,
                To => $r->param('to'),
                Subject => $r->param('subject'),
                Data => $r->param('message'),
                # smtp_host => $smtp_host,
                attachment => \%attachment,
            ) or return SERVER_ERROR;

    print <<HERE;
      <html>
        <body>
          Your message has been sent
        </body>
      </html>
HERE
  }
  else {
    # Print out a web form.
    print <<HERE;
      <html>
        <body>
          <b>Email a file...</b>
          <form method="post" enctype="multipart/form-data">
            To:<input type="text" name="To" size="24"><br/>
            Subject:<input type="text" name="subject" size="24"><br/>
            Attachment:<input type="file" name="upload" size="16"><br/>
            Message:</br>
            <textarea name="message" cols="40" rows="4"></textarea><br/>
            <input type="submit"><br/>
          </form>
        </body>
      </html>
HERE
  }
}
1;
