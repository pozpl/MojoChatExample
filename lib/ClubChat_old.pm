package ClubChat;
use Mojo::Base 'Mojolicious';
# Normal route to controller
use DateTime;
use Mojo::JSON;
# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  my $clients = {};
  my %clients_zones = ();
    
  $r->get('/' => 'index');
    
#  $r->get('/chat' => sub {
#  	my $self = shift;
#  	$self->render(message => 'Welcome');
#  });  
    
  $r->websocket('/chat' => sub {
        my $self = shift;
    
        $self->app->log->debug(sprintf 'Client connected: %s', $self->tx);
        my $id = sprintf "%s", $self->tx;
        $clients->{$id} = $self->tx;
        Mojo::IOLoop->stream($self->tx->connection)->timeout(0);#disable websoket timeout
        $self->on(message =>
            sub {
                my ($self, $msg) = @_;
    
                my $json = Mojo::JSON->new;
                my $dt   = DateTime->now( time_zone => 'Asia/Tokyo');

                for (keys %$clients) {
                    $clients->{$_}->send(
                        $json->encode({
                            hms  => $dt->hms,
                            text => $msg,
                        })
                    );
                }
            }
        );

        $self->on(finish =>
            sub {
                $self->app->log->debug('Client disconnected');
                delete $clients->{$id};
            }
        );
    });

}

1;
