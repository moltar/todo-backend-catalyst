package Todo::Backend::TraitFor::Response::JSON;

use Moose::Role;
use namespace::autoclean;

=head2 json

Store temporary HashRef or ArrayRef or undef to be JSON encoded in the view.

=cut

has json => (
    is  => 'rw',
    isa => 'HashRef|ArrayRef|Undef',
);

1;
