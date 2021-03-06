package Todo::Backend::Store;

use Moose;
use UUID::Tiny qw();
use DBM::Deep;
use namespace::autoclean;

=head2 database

Path to the file which is used to store the data.

=cut

has database => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has _items => (
    is      => 'ro',
    isa     => 'DBM::Deep',
    lazy    => 1,
    builder => '_build__items',
);

sub _build__items {
    my $self = shift;

    return DBM::Deep->new(
        file    => $self->database,
        locking => 1,
    );
}

=head2 get( $item_id )

Get a todo item by ID.

=cut

sub get {
    my ( $self, $item_id ) = @_;

    my $item = $self->_items->get( $item_id );

    return unless $item;

    ## shallow clone the item, because it might get modified later
    return { %{$item} };
}

=head2 list()

Return a list of ordered todo items.

=cut

sub list {
    my ( $self ) = @_;

    ## Slightly hairy "one liner". Let's break it down from the end.
    ## 1. Get a list of item IDs.
    ## 2. Built in map function will call a block on each item ID, and get() the item (shallow cloned).
    ## 3. Then we sort the items based on the order value.
    ## 4. And finally return an ArrayRef of items [ ... ].
    return [ sort { $a->{order} <=> $b->{order} } map { $self->get( $_ ) } keys %{ $self->_items } ];
}

=head2 add( \%item )

Add a new todo item.

=cut

sub add {
    my ( $self, $item ) = @_;

    my $item_id = $self->_generate_item_id;

    $self->_items->put(
        $item_id,
        {
            # default value
            completed => 0,
            order     => 0,

            # user supplied values
            %{$item},

            # ID is always generated, and cannot be supplied by user
            id => $item_id,
        }
    );

    return $self->get( $item_id );
}

=head2 edit( $item_id, \%changes )

Modify a todo item.

=cut

sub edit {
    my ( $self, $item_id, $changes ) = @_;

    ## Deflate/stringify boolean value coming in from JSON, as DBM::Deep
    ## cannot deal with it (cannot store scalar references)
    if ( exists $changes->{completed} ) {
        $changes->{completed} = $changes->{completed} ? 1 : 0;
    }

    ## Cannot change the ID
    if ( exists $changes->{id} ) {
        delete $changes->{id};
    }

    if ( my $item = $self->_items->get( $item_id ) ) {
        foreach my $key ( keys %{$changes} ) {
            $item->{$key} = $changes->{$key};
        }

        return $self->get( $item_id );
    }

    return;
}

=head2 clear()

Remove all items from the todo list.

=cut

sub clear {
    my ( $self ) = @_;

    return $self->_items->clear;
}

=head2 delete( $item_id )

Delete a single item given a C<$item_id>.

=cut

sub delete {
    my ( $self, $item_id ) = @_;

    return $self->_items->delete( $item_id );
}

#--------------------------------------------------------------------------#
# Private Methods
#--------------------------------------------------------------------------#

sub _generate_item_id {
    return UUID::Tiny::create_uuid_as_string();
}

__PACKAGE__->meta->make_immutable;

1;
