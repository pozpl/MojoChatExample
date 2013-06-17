package ClubChat::MessagesPupSub::SubscriptionsService;

use warnings;
use strict;

use Moo;
use AnyEvent::Redis::RipeRedis;
use JSON;

#redis connection handler
has 'redis_handler' => ('is' => 'ro', 'required' => 1,);

#channel to subscribe
has 'channel' => ('is' => 'ro', 'required' => 1,);
 
sub publicate_message(){
	my ($self, $message_href) = @_;
	my $encoded_message = encode_json($message_href);
	$self->redis_handler->publish(
	   $self->channel,
	   $encoded_message
	);
	return 1;
} 
 
sub subscribe_for_message(){
	my ($self, $connections_groups_href) = @_;
	 my $redis_subscription_handler->subscribe( $self->channel, {           
           on_message => sub {
             my $ch_name = shift;
             my $msg = shift;
             $self->__parse_income_message($msg, $connections_groups_href);
           },           
         } );
	
}

sub __parse_incoming_message(){
	my ($self, $msg, $connections_groups_href) = @_;
	
	my $message_href = decode_json($msg);
	my $group_id = $message_href->{'group_id'};
	if(exists $connections_groups_href->{$group_id}){
		my $group_connections = $connections_groups_href->{$group_id};
		$self->__resend_to_group($message_href, $group_connections); 
	}
	
}

sub __resend_to_group(){
	my ($self, $message_href,$group_connections_href) = @_;
	
	for my $ws_connection (values %{$group_connections_href}){
		my $msg_json_text = encode_json($message_href);
		$ws_connection->send($msg_json_text);
	} 
}

1;

