package ClubChat::MessagesPupSub::SubscriptionsService;


use warnings;
use strict;

use Moo;
use AnyEvent::Redis::RipeRedis;
use JSON;
use Data::Dump  qw(dump);

#redis subscription connection handler
has 'redis_subscription_handler' => ('is' => 'ro', 'required' => 1,);

#redis publishing connection handler
has 'redis_publishing_handler' => ('is' => 'ro', 'required' => 1,);

#channel to subscribe
has 'channel' => ('is' => 'ro', 'required' => 1,);

sub publicate_message(){
	my ($self, $message_href) = @_;
	print "publication stopt";
	my $encoded_message = encode_json($message_href);	
	my $publicator = &{$self->redis_publishing_handler};	
	$publicator->publish(
	   $self->channel,
	   $encoded_message
	);
	return 1;
} 
 
sub subscribe_for_message(){
	my ($self, $connections_groups_href) = @_;
	my $subscribtion = &{$self->redis_subscription_handler};
	$subscribtion->subscribe( ($self->channel), {           
          on_message => sub {          	 
             my $ch_name = shift;
             my $msg = shift;
             print "subscribed message $msg\n";
             $self->__parse_incoming_message($msg, $connections_groups_href);
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
	print "resend to group\n";
	for my $ws_connection (values %{$group_connections_href}){
		my $msg_json_text = encode_json($message_href);
		$ws_connection->send($msg_json_text);
	} 
}

1;

