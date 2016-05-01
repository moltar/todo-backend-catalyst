use warnings;
use strict;

use Test::More;
use File::Temp qw();
use UUID::Tiny qw(is_uuid_string);
use Scalar::Util qw(refaddr);
use JSON::MaybeXS;

use_ok 'Todo::Backend::Store';

test(
    'add',
    sub {
        my $store = shift;

        my $input = { title => 1 };
        my $item1 = $store->add( $input );
        is $item1->{completed}, 0, 'completed defaults to false';
        is $item1->{order},     0, 'order defaults to 0';
        is $item1->{title},     1, 'item title is set to 1';
        ok $item1->{id},        'item id is set';
        ok is_uuid_string( $item1->{id} ), 'id is a UUID';
        isnt refaddr( $item1 ), refaddr( $input ), 'item was shallow cloned';

        ## make sure we cannot override the ID
        my $item2 = $store->add( { title => 2, id => 1 } );
        ok is_uuid_string( $item2->{id} ), 'id is a UUID';

        ## make sure we can override completed & order
        my $item3 = $store->add( { completed => 1, order => 1 } );
        is $item3->{completed}, 1, 'completed was overridden';
        is $item3->{order},     1, 'order was overridden';
    },
);

test(
    'get',
    sub {
        my $store = shift;

        my $item_created = $store->add( { title => 1 } );
        my $item_get = $store->get( $item_created->{id} );

        ok $item_get, 'got the item';
        is $item_get->{title}, 1, 'item title is 1';
        isnt refaddr( $item_created ), refaddr( $item_get ), 'item was shallow cloned';
    },
);

test(
    'list',
    sub {
        my $store = shift;

        for ( my $i = 5 ; $i > 0 ; $i-- ) {
            $store->add( { title => $i, order => $i } );
        }

        my $items = $store->list;

        is @{$items}, 5, 'got 5 items';
        is_deeply [ 1, 2, 3, 4, 5 ], [ map { $_->{order} } @{$items} ], 'item order is correct';
    }
);

test(
    'edit',
    sub {
        my $store = shift;

        my $item = $store->add( { title => 1 } );

        my $item_edited = $store->edit(
            $item->{id},
            {
                title     => 2,
                id        => 'foo',
                completed => JSON->true,
            }
        );

        is $item_edited->{id}, $item->{id}, 'id has not changed';
        is $item_edited->{completed}, 1, 'completed <true> has been deflated to 1';
        is $item_edited->{title},     2, 'title is 2';

        is $store->edit( 'wrong', {} ), undef, 'editing non-existing item returns undef';
    }
);

test(
    'clear',
    sub {
        my $store = shift;

        $store->add( { title => 1 } );
        ok $store->clear, 'Clear the store of all items';
        is @{ $store->list }, 0, 'Store contains 0 items.';
    }
);

test(
    'delete',
    sub {
        my $store = shift;

        my $item = $store->add( { title => 1 } );
        is @{ $store->list }, 1, 'Store contains 1 item.';
        ok $store->delete( $item->{id} ), 'Clear the store of all items';
        is @{ $store->list }, 0, 'Store contains 0 items.';
    }
);

sub test {
    my ( $name, $sub ) = @_;

    subtest $name => sub {
        my $fh = File::Temp->new(
            SUFFIX => '.db',
            OPEN   => 0,
            EXLOCK => 0,
        );
        my $db_file = $fh->filename;

        my $store = new_ok( 'Todo::Backend::Store', [ database => $db_file ] );
        return $sub->( $store );
    };
}

done_testing;
