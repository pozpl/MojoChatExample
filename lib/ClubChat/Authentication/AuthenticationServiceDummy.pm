package ClubChat::Authentication::AuthenticationServiceDummy;

=pod
=head1 ClubChat::Authentication::AuthenticationServiceDummy;
=head2 SYNOPSYS
This package is stub object that will pass everyone because I do not
have mutch time to implement proper one
=cut

use warnings;
use strict;
use Moo;

with('ClubChat::Authentication::AuthenticationServiceRole');

sub is_user_key_registred_in_group(){
    return 1;   
}
sub is_authorised(){
    return 1;   
}

1;