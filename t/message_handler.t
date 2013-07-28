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
use ClubChat::Authentication::AuthenticationServiceDummy;
use ClubChat::MessagesHandler;
use ClubChat::RedisConnection::AnyEventRedis;
my $cv = AE::cv();

#my $redis = AnyEvent::Redis::RipeRedis->new(
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
my $anyEventRedis = ClubChat::RedisConnection::AnyEventRedis->new(); 
my $redis = $anyEventRedis->getConnectionSubscribe('127.0.0.1'); 
    
my $redis_pub = $anyEventRedis->getConnectionPublicate('127.0.0.1');
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

my $authenticationServiece = ClubChat::Authentication::AuthenticationServiceDummy->new();
my $message_handler = ClubChat::MessagesHandler->new({
	'authentication_service' => $authenticationServiece,
	'message_registrator' => $subscription_service,
});

my $auth_message = {
    'type' => 'auth',
    'auth_key' => 'simple_auth_key',
    'group_id' => 1234
}; 
my $chat_message = {
    'type' => 'msg',
    'group_id' => 1234,
    'text' => 'some fancy text',    
};
my $ws_connection = Test::MockObject->new(); 
$ws_connection->mock('send', sub{
    my ($self, $message_json) = @_;
    print ($message_json);
    ok(1, 'Message is send to an ws connection');
    ok(encode_json($chat_message) eq $message_json, 'Messages are the same ' . $message_json);
    $cv->send();
    return 1;    
});

my $connection_id = 'connection_1';

my %connections_groups = (
    $auth_message->{'group_id'} => {
        $connection_id => $ws_connection,
    }
);

my $new_connections = {
	$connection_id => $ws_connection,
};
my $connection_id_group_id_map = {};

my $connections_env_href = {
                            'new_connections'    => $new_connections,
                            'connections_groups' => \%connections_groups,
                            'connection_id_group_id_map' => $connection_id_group_id_map,
                        };

my $publish_watcher  = AnyEvent->timer('after' => 1, 'cb'=> sub{
    $message_handler->handle_message(encode_json($auth_message), $connection_id, $connections_env_href);
    $message_handler->handle_message(encode_json($chat_message), $connection_id, $connections_env_href);
});

$subscription_service->subscribe_for_message(\%connections_groups);

$cv->recv();

#$redis->disconnect();

