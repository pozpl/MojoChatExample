package Authentication::ClubChat::AuthenticationServiceRedis;

use warnings;
use strict;
use Moo;

with('ClubChat::Authentication::AuthenticationServiceRole');

#redis connection
has 'redis' => ('is' => 'ro', 'required' => 1,);


sub is_authorised(){
    my ($self, $userKey, $groupId) = @_;
    
    	
}

sub is_user_key_registred_in_group(){
	return 1;
}

1;