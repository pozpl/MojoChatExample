package ClubChat::Authentication::AuthenticationServiceRole;

use Moo::Role;

requires qw(is_authorised is_user_key_registred_in_group);

sub is_authorised(){
	my ($self, $auth_key, $group_id) = @_;
	
	return $self->is_user_key_registred_in_group();
}

1;