package ClubChat;
use Mojo::Base 'Mojolicious';

# Normal route to controller
use DateTime;
use JSON;
use File::Basename;
use EV;
use AnyEvent;
use Data::Dump qw(dump);

my $BEANS_CONF_PATH = "/../config/beans.yml";

sub testing_mode() {
	my $self = shift;
	$BEANS_CONF_PATH = "/../config/beans_test.yml";
}

# This method will run once at server start
sub startup {
	my $self = shift;

	my $current_working_directory = dirname(__FILE__);
    
    print "initialysing beans\n";
	$self->plugin( 'BeamWire',
		{ 'beans_conf' => $current_working_directory . $BEANS_CONF_PATH, } );

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	my $new_connections            = {};
	my $clients_zones              = {};
	my $connection_id_group_id_map = {};
	
#	my $cv = AE::cv;
	
    my $message_handler = $self->get_bean('messages_handler');
	my $subscription_service = $self->get_bean('subscriptions_service');
    
    $self->hook(after_build_tx => sub {
            my ($tx, $app) = @_;
            $subscription_service->subscribe_for_message($clients_zones);
            print "subscribed for messages\n";
    });
    
    
	$r->get( '/' => 'index' );

	$r->websocket(
		'/chat' => sub {
			my $self = shift;
                    
			$self->app->log->debug( sprintf 'Client connected: %s', $self->tx );
			my $id = sprintf "%s", $self->tx;
			$new_connections->{$id} = $self->tx;
			Mojo::IOLoop->stream( $self->tx->connection )->timeout(0); #disable websoket timeout

			$self->on(
				message => sub {
					my ( $self, $msg ) = @_;
					print "message arrived to connection $id\n";                    
					my $message_status = $message_handler->handle_message(
						$msg, $id,
						{
							'new_connections'    => $new_connections,
							'connections_groups' => $clients_zones,
							'connection_id_group_id_map' => $connection_id_group_id_map,
						}
					);
					
#					dump($new_connections);
#					dump($clients_zones);
					dump($connection_id_group_id_map);
					$self->tx->send(encode_json({
						'type' => 'status', 
						'status' => $message_status,
					}));
	
				}
			);

			$self->on(
				finish => sub {
					$self->app->log->debug('Client disconnected');
					delete $new_connections->{$id};
				}
			);
		}
	);
	
#	 $cv->recv();

}

1;
