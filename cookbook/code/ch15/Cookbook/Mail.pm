package Cookbook::Mail;

use Email::Valid;
use Exporter;
use MIME::Lite;
use MIME::Types;

use 5.6.0;
use strict;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(send_mail);

sub send_mail {

  my ($r, %args) = @_;

  my $log = $r->server->log;

  # Check for an SMTP host (demanding one for Win32),
  # and configure MIME::Lite to use it if present.
  my $smtp_host = delete $args{smtp_host};

  if ($^O =~ m/Win32/ and !$smtp_host) {
    $log->error("Please specify an SMTP host");
    return;
  }

  MIME::Lite->send('smtp', $smtp_host, Timeout => 60) if $smtp_host;

  # Make sure From, To, and Subject headers are present.
  foreach my $header (qw(From To Subject)) {
    unless ($args{$header}) {
      $log->error("Please supply the '$header' field");
      return;
    }
  }
  
  # Use Email::Valid to check the validity of the To header.
  unless (Email::Valid->address($args{To})) {
    $log->error("$args{To} doesn't seem to be a valid address");
    return;
  }
    
  # Make sure either Data (a scalar or an array ref), Path (a filename),
  # or FH (a filehandle) is given for the message body.
  unless (grep { $args{$_} } qw(Data Path FH)) {
    $log->error("Specify 'Data', 'Path', or 'FH' for the message body");
    return;
  }

  # See if an attachment is present.
  my $attachment = delete $args{attachment};

  # Create the basic message.
  my $msg = MIME::Lite->new(%args, Type => 'TEXT');
 
  # If an attachment is present, add it to the message
  # using MIME::Types to set the Content-Type header.
  if ($attachment) {
    if (-r $attachment->{file}) {
      my ($type, $encoding) = MIME::Types::by_suffix($attachment->{name});
      $msg->attach(Path => $attachment->{file},
                   Filename => $attachment->{name},
                   Type => $type);
    }
    else {
      $log->error("Cannot read ", $attachment->{name});
      return;
    }
  }

  # Now send the message.
  unless ($msg->send ) {
    $log->error("Could not send message");
    return;
  }
  
  return 1;
}
1;
