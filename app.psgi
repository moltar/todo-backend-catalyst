use strict;
use warnings;

use lib './lib';
use Todo::Backend;
use Plack::Builder;
use Plack::Middleware::CrossOrigin;

my $app = Todo::Backend->apply_default_middlewares( Todo::Backend->psgi_app );

builder {
    enable_if { $_[0]->{HTTP_X_FORWARDED_FOR} } 'ReverseProxy';

    enable 'CrossOrigin',
      origins => '*',
      methods => '*',
      headers => ['Content-Type'];

    $app;
};
