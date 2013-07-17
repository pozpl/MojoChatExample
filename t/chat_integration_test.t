use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use JSON;
use ClubChat;


my $t = Test::Mojo->new('ClubChat');

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
my $chat_message_json = encode_json($chat_message);

$t->websocket_ok('/chat')
  ->send_ok(encode_json($auth_message))
  ->message_ok
  ->message_is('1')
  ->send_ok($chat_message_json)
  ->message_ok
  ->message_is('1')
  ->message_ok
  ->message_is($chat_message_json)
  
  ->finish_ok;


done_testing();
