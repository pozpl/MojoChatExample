package ClubChat::MessagesHandler;

=perldoc
=header1 Synopsys
This module purpose is to handle new messages 
=cut

use Moo;
use JSON;

#service to authenticate connections
has 'authentication_service' => (
    'is' => 'ro',
    'isa' => sub{
        if(! $_[0]->does('ClubChat::Authentication::AuthenticationServiceRole')){
            die "authentication_service does not implements ClubChat::Authentication::AuthenticationServiceRole";
        }
    },
    'required' => 1,
);

#service to register message in public/subscribe sistem
has 'message_registrator' => (
    'is' => 'ro',
    'isa' => sub{
        if(! $_[0]->isa('ClubChat::MessagesPupSub::SubscriptionsService')){
            die "message_registrator does not implements ClubChat::MessagesPupSub::SubscriptionsService";
        }
    },
    'required' => 1,
);

sub handle_message(){
	my ($self, $message_json, $connection_id, $connections_env_href) =@_;
	my $message = JSON->new->decode($message_json);
	
	my $message_processing_status = 0;
	if( $message->{'type'} eq 'auth'){		
		my $auth_key = $message->{'auth_key'};
		my $group_id = $message->{'group_id'};
        $message_processing_status = $self->__process_authentication($connections_env_href,  $auth_key, $connection_id, $group_id);
	}elsif($message->{'type'} eq 'msg'){
		$message_processing_status = $self->__register_message($message, $connection_id, $connections_env_href);
	}	  
	return $message_processing_status;
}

############################################
# Usage      : $is_authenticated = $self->__process_authentication('message_key_12312', 'connection_id', 'connection_group_id_121');
# Purpose    : handle user authentication message and if it authenticated move user to corresponding room
# Returns    : 1 if user is authenticated 0 otherwise
# Parameters : message key to authenticate
#              connection_id - id of a websocket connection
#              connection_group_id - id of a group to wich a user wants to participate
# Throws     : no exceptions
# Comments   : ???
# See Also   : n/a
sub __process_authentication(){
	my ($self, $connections_env_href,  $auth_key, $connection_id, $group_id) = @_;
	my $new_connections = $connections_env_href->{'new_connections'};
	my $connection_groups = $connections_env_href->{'connections_groups'};
	my $connection_id_group_map = $connections_env_href->{'connection_id_group_id_map'};
	my $is_authorised = $self->authentication_service->is_authorised($auth_key, $group_id);
	if($is_authorised 
	   && exists $new_connections->{$connection_id}){		
		$connection_groups->{$group_id}->{$connection_id} = $new_connections->{$connection_id};
		$connection_id_group_map->{$connection_id} = $group_id; 
		delete $new_connections->{$connection_id};
	}
	return $is_authorised;
}


############################################
# Usage      : $is_authenticated = $self->__register_message(\%message_hash, 'connection_id_2342');
# Purpose    : put user message into publicate/subscribe mediator to another services to obtain
# Returns    : 1 if message was registred in the system 0 otherwise
# Parameters : message_href - a hash reference for a message structure
#              connection_id - id of a websocket connection
# Throws     : no exceptions
# Comments   : ???
# See Also   : n/a
sub __register_message(){
	my ($self, $message_href, $connection_id, $connections_env_href) = @_;
	
	my $group_id = $message_href->{'group_id'};
	
	my $message_publicated = 0;
	if(exists $connections_env_href->{'connections_groups'}->{$group_id}->{$connection_id}){		
		$message_publicated = $self->message_registrator->publicate_message($message_href);
	}
	
	return $message_publicated;
}


1;