use TAP::Harness;

use File::Basename;

my $harness_working_directory  = dirname(__FILE__);

my %args = (
    verbosity => 1,
    lib     => [ 'lib', $harness_working_directory .'/../lib','blib/lib', 'blib/arch' ],
 );
 my $harness = TAP::Harness->new( \%args );
 
 
 ################Prepare some data#################
 
 
 my @tests = (
    $harness_working_directory . '/message_handler.t', 
    $harness_working_directory . '/subscription_service.t', 
    $harness_working_directory . '/chat_integration_test.t',
 );
 $harness->runtests(@tests);
 