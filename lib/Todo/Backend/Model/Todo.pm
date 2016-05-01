package Todo::Backend::Model::Todo;

use warnings;
use strict;

use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Todo::Backend::Store' );

1;
