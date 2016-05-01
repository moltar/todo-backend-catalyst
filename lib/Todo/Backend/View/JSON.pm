package Todo::Backend::View::JSON;

use Moose;
use JSON::MaybeXS;
use namespace::autoclean;

extends 'Catalyst::View::JSON';

__PACKAGE__->config(
    {
        expose_stash      => 'json',
        json_encoder_args => {
            canonical => 1,
            pretty    => 1,
        },
    }
);

before process => sub {
    my ( $self, $c ) = @_;

    my $ref = $c->stash->{ $self->expose_stash };

    if ( $ref && ref( $ref ) eq 'HASH' ) {
        $self->filter( $c, $ref );
    }
    elsif ( $ref && ref( $ref ) eq 'ARRAY' ) {
        foreach my $item ( @{$ref} ) {
            $self->filter( $c, $item );
        }
    }
};

sub filter {
    my ( $self, $c, $item ) = @_;

    $item->{url} = $c->uri_for( $c->controller( 'Root' )->action_for( 'get_item' ), $item->{id} )->as_string;

    ## Since Perl does not have true booleans, but JSON does, we need to convert
    ## SCALAR pseudo-boolean to an actual JSON boolean
    if ( exists $item->{completed} ) {
        $item->{completed} = $item->{completed} ? JSON->true : JSON->false;
    }

    ## Make sure that the order is actually an integer and not a string
    if ( exists $item->{order} ) {
        $item->{order} = int( $item->{order} );
    }
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
