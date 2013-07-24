package ClubChat::RedisConnection::AnyEventRedis;

use strict;
use warnings;
use Moo;

sub getConnectionPublicate() {
	my ($self, $address) = @_;
	my $redis = 0;
	return sub {
        if ( !$redis ) {	   
			$redis = AnyEvent::Redis::RipeRedis->new(
				host     => $address,
				port     => '6379',
				#password => 'yourpass',
				encoding => 'utf8',
				on_error => sub {
					my $err_msg  = shift;
					my $err_code = shift;

					# handle the error
				},
			);			
		}
		return $redis;
	  }

}

sub getConnectionSubscribe() {
	my ($self, $address) = @_;
	my $redis = 0;
	return sub {
        if ( !$redis ) {	   
			$redis = AnyEvent::Redis::RipeRedis->new(
				host     => $address,
				port     => '6379',
				#password => 'yourpass',
				encoding => 'utf8',
				on_error => sub {
					my $err_msg  = shift;
					my $err_code = shift;

					# handle the error
				},
			);			
		}
		return $redis;
	  }

}
1;
