package Mojolicious::Plugin::BeamWire;

use Mojo::Base 'Mojolicious::Plugin';
use Beam::Wire;
our $VERSION = '0.1';

has conf => sub { +{} };

sub register {
	my ( $plugin, $app, $conf ) = @_;
    
    if(! (exists($conf->{'beans_conf'}) && -e $conf->{'beans_conf'})){
    	die "Beans config file is not set!!!";
    }
    my $wire  = Beam::Wire->new( file => $conf->{'beans_conf'} );
	$plugin->conf($conf) if $conf;

	$app->helper(
		get_bean => sub {
			my ($self, $bean_name) = @_;
			return $wire->get($bean_name);
		},
		
		add_bean => sub {
			my ($self, $bean_name, $object) = @_;
			return $wire->set( $bean_name, $object );
		}
	);
	
}

1;

