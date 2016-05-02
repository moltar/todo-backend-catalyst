package Todo::Backend::TraitFor::Request::JSON;

use Moose::Role;
use namespace::autoclean;

=head2 json

If we have JSON request, decodes it and stores it in the attribute.

=cut

has json => (
    is      => 'ro',
    isa     => 'HashRef|ArrayRef|Undef',
    lazy    => 1,
    builder => '_build_json',
);

sub _build_json {
    my $self = shift;

    my $content_type = $self->content_type || return {};

    if ( $content_type =~ m{^application/json}i ) {
        return $self->data_handlers->{'application/json'}->( $self->body, $self );
    }

    return {};
}

1;
