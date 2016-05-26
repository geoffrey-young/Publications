package HalfLife::QueryServer;

use IO::Socket;
use NetPacket::IP;
use NetPacket::UDP;
use Data::Dumper;

use strict;

sub new {

  my $self  = shift;
  my $class = ref($self) || $self;

  my ($server, $port) = @_;

  return bless { _ip   => $server,
                 _port => $port || 27015 
  }, $class;
}


sub ping {
  my $self   = shift;

  my $server = IO::Socket::INET->new(PeerAddr => $self->{_ip},
                                     PeerPort => $self->{_port},
                                     Proto    => 'udp',
                                     Timeout  => 5,
                                     Type     => SOCK_DGRAM)
    or die "could't open socket: $!";

  $server->send("\xFF\xFF\xFF\xFFdetails\x00");
  $server->recv(my $packet, 1024);

  return $self->_parse_response($packet);
}

sub remotequery {
  # Query the server and return some results, all in one command.

  my $self = new(@_);

  $self->ping();

  return [$self->{_os}, $self->{_type}, 
          $self->{_map}, $self->{_description}]; 
}

sub ip {

  my $self = shift;

  return $self->{_ip} unless @_;

  return $self->{_ip} = shift;
}

sub port {

  my $self = shift;

  return $self->{_port} unless @_;

  return $self->{_port} = shift;
}

sub os {
  return shift->{_os};
}

sub type {
  return shift->{_type};
}

sub map {
  return shift->{_map};
}

sub description {
  return shift->{_description};
}

sub server {
  return shift->{_server};
}

sub _parse_response {

  my ($self, $packet) = @_;

  my $response = NetPacket::UDP->decode($packet);

  my ($address, $server, $map, $directory, $description,
      $decode_me, $info, $ftp, $version, $bytes, 
      $servermod, $customclient) = split /\0/, $response->{data};

  my ($active, $max, $proto, $type, $os, $password, $mod) = 
    map { ord(substr($decode_me,$_,1)) } (0 .. 6);
                
  $self->{_os} = $os eq 'l' ? 'linux' : 'windows';
  $self->{_type} = $type eq 'd' ? 'dedicated' : 'listener';
  $self->{_map} = $map;
  $self->{_description} = $description;
  $self->{_server} = $server;
}
1;

