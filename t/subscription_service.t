use Test::Simple tests => 2;
use warnings;
use strict;
use lib '../lib';

use ClubChat::MessagesPupSub::SubscriptionsService;
use Test::MockObject;
use AnyEvent;
use AnyEvent::Redis::RipeRedis qw( :err_codes );
#use AnyEvent::Redis;
use Redis;
use JSON;
use ClubChat::RedisConnection::AnyEventRedis;

my $cv = AE::cv();

#my $redis = AnyEvent::Redis::RipeRedis->new(
#	host     => '127.0.0.1',
#	port     => '6379',
#	#password => 'yourpass',
#	encoding => 'utf8',
#	on_error => sub {
#		my $err_msg  = shift;
#		my $err_code = shift;
#
#		print "$err_msg $err_code\n";
#	},
#	);
my $anyEventRedis = ClubChat::RedisConnection::AnyEventRedis->new(); 
my $redis = $anyEventRedis->getConnection('127.0.0.1'); 
	
my $redis_pub = $anyEventRedis->getConnection('127.0.0.1'); 
#AnyEvent::Redis::RipeRedis->new(
#    host     => '127.0.0.1',
#    port     => '6379',
#    #password => 'yourpass',
#    encoding => 'utf8',
#    on_error => sub {
#        my $err_msg  = shift;
#        my $err_code = shift;
#
#        print "$err_msg $err_code\n";
#    },
#    );


my $subscription_service = ClubChat::MessagesPupSub::SubscriptionsService->new(
{
	'redis_subscription_handler' => $redis,
	'redis_publishing_handler' => $redis_pub,
	'channel' => 'some_channel_name',
});



my %message = (
    'group_id' => 'group_1',
    'text' => 'text simple', 
);

my $publish_watcher  = AnyEvent->timer('after' => 1, 'cb'=> sub{
	$subscription_service->publicate_message(\%message)
});

my $send_via_ws_message; 
my $ws_connection = Test::MockObject->new(); 
$ws_connection->mock('send', sub{
	my ($self, $message_json) = @_;
	$send_via_ws_message = 1;
	print ($message_json);
	ok(1, 'Message is send to an ws connection');
	ok(encode_json(\%message) eq $message_json, 'Messages are the same ' . $message_json);
	$cv->send();
    return 1;    
});

my %connections_groups = (
    $message{'group_id'} => {
        'connection_1' => $ws_connection,
    }
);

$subscription_service->subscribe_for_message(\%connections_groups);

$cv->recv();

#$redis->disconnect();

