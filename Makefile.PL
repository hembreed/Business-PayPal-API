use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Business::PayPal::API',
    VERSION_FROM      => 'lib/Business/PayPal/API.pm',
    PREREQ_PM         => { SOAP::Lite => 0.67 },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Business/PayPal/API.pm',
       AUTHOR         => 'Scott Wiersdorf <scott@perlcode.org>') : ()),
);
