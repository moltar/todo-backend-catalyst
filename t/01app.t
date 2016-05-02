#!/usr/bin/env perl

my ( $fh, $db );

BEGIN {
    use File::Temp qw();
    my $fh = File::Temp->new(
        SUFFIX => '.db',
        OPEN   => 0,
        EXLOCK => 0,
    );
    my $db = $fh->filename;
    $ENV{TODO_DATABASE} = $db;
}

use strict;
use warnings;

use Test::More;
use JSON::MaybeXS;
use HTTP::Request;

use Catalyst::Test 'Todo::Backend';

subtest 'the pre-requisites' => sub {
    subtest 'the api root responds to a GET (i.e. the server is up and accessible)' => sub {
        my ( $res ) = req( 'get', '/' );
        ok $res->is_success, 'request should succeed';
    };

    subtest 'the api root responds to a POST with the todo which was posted to it' => sub {
        my ( $res, $ref ) = req( 'post', '/', { title => 'a todo' } );
        ok $res->is_success, 'request should succeed';
        is $ref->{title}, 'a todo', 'title is returned';
    };

    subtest 'the api root responds successfully to a DELETE' => sub {
        my ( $res ) = req( 'delete', '/' );
        ok $res->is_success, 'request should succeed';
    };

    subtest 'after a DELETE the api root responds to a GET with a JSON representation of an empty array' => sub {
        my ( $res, $ref ) = req( 'get', '/' );
        ok $res->is_success, 'request should succeed';
        is_deeply $ref, [], 'got an empty array';
    };
};

subtest 'storing new todos by posting to the root url' => sub {
    subtest 'adds a new todo to the list of todos at the root url' => sub {
        my ( $res1 ) = req( 'post', '/', { title => 'walk the dog' } );
        ok $res1->is_success, 'post request should succeed';

        my ( $res2, $ref ) = req( 'get', '/' );
        ok $res2->is_success, 'get request should succeed';
        is @{$ref}, 1, 'have 1 item';
        is $ref->[0]{title}, 'walk the dog', 'title is walk the dog';
    };

    subtest 'sets up a new todo as initially not completed' => sub {
        my ( $res1, $ref ) = req( 'post', '/', { title => 'walk the dog' } );
        ok $res1->is_success, 'post request should succeed';
        ok !$ref->{completed}, 'is not completed';
    };

    subtest 'each new todo has a url' => sub {
        my ( $res1, $ref ) = req( 'post', '/', { title => 'walk the dog' } );
        ok $res1->is_success, 'post request should succeed';
        ok $ref->{url}, 'has url property';
        like $ref->{url}, qr{^http}, 'looks like URL';
    };

    subtest 'each new todo has a url, which returns a todo' => sub {
        my ( $res1, $ref1 ) = req( 'post', '/', { title => 'walk the dog' } );
        ok $res1->is_success, 'post request should succeed';

        my ( $res2, $ref2 ) = req( 'get', $ref1->{url} );
        ok $res2->is_success, 'get request should succeed';

        is $ref2->{title}, 'walk the dog', 'title is walk the dog';
    };
};

subtest 'working with an existing todo' => sub {
    subtest 'can navigate from a list of todos to an individual todo via urls' => sub {
        my ( $res1, $ref ) = req( 'get', '/' );
        ok $res1->is_success, 'get list request should succeed';

        my ( $res2 ) = req( 'get', $ref->[0]{url} );
        ok $res2->is_success, 'get item request should succeed';
    };

    subtest "can change the todo's title by PATCHing to the todo's url" => sub {
        my ( $res1, $ref1 ) = req( 'post', '/', { title => 'initial title' } );
        ok $res1->is_success, 'post request should succeed';

        my ( $res2, $ref2 ) = req( 'patch', $ref1->{url}, { title => 'bathe the cat' } );
        ok $res2->is_success, 'patch request should succeed';
        is $ref2->{title}, 'bathe the cat', 'title has changed';
    };

    subtest "can change the todo's completedness by PATCHing to the todo's url" => sub {
        my ( $res1, $ref1 ) = req( 'post', '/', { title => 'initial title' } );
        ok $res1->is_success, 'post request should succeed';
        ok !$ref1->{completed}, 'completed is false';

        my ( $res2, $ref2 ) = req( 'patch', $ref1->{url}, { completed => JSON->true } );
        ok $res2->is_success, 'patch request should succeed';
        ok $ref2->{completed}, 'completed is true';
    };

    subtest 'changes to a todo are persisted and show up when re-fetching the todo' => sub {
        my ( $res1, $ref1 ) = req( 'post', '/', { title => 'initial title' } );
        ok $res1->is_success, 'post request should succeed';
        ok !$ref1->{completed}, 'completed is false';

        my ( $res2, $ref2 ) = req( 'patch', $ref1->{url}, { completed => JSON->true, title => 'changed title' } );
        ok $res2->is_success, 'patch request should succeed';
        ok $ref2->{completed}, 'completed is true';
        is $ref2->{title}, 'changed title', 'changed title';
    };

    subtest "can delete a todo making a DELETE request to the todo's url" => sub {
        my ( $res1, $ref1 ) = req( 'post', '/', { title => 'initial title' } );
        ok $res1->is_success, 'post request should succeed';

        my ( $res2, $ref2 ) = req( 'delete', $ref1->{url} );
        ok $res2->is_success, 'delete request should succeed';

        my ( $res3 ) = req( 'get', $ref1->{url} );
        ok !$res3->is_success, 'after deletion item is not accessible';
    };
};

subtest 'tracking todo order' => sub {
    my ( $res1, $ref1 ) = req( 'post', '/', { title => 'initial title', order => 10 } );
    ok $res1->is_success, 'post request should succeed';

    subtest 'can create a todo with an order field' => sub {
        is $ref1->{order}, 10, 'order is 10';
    };

    subtest 'can PATCH a todo to change its order' => sub {
        my ( $res2 ) = req( 'patch', $ref1->{url}, { order => 20 } );
        ok $res2->is_success, 'patch request should succeed';
    };

    subtest "remembers changes to a todo's order" => sub {
        my ( $res3, $ref3 ) = req( 'get', $ref1->{url} );
        ok $res3->is_success, 'get request should succeed';
        is $ref3->{order}, 20, 'order is 20';
    };
};

{
    my $json;

    sub req {
        my ( $method, $uri, $data ) = @_;
        $json ||= JSON::MaybeXS->new( utf8 => 1 );

        my $header = [ 'Content-Type', 'application/json' ];
        my $content = $data ? $json->encode( $data ) : q{};

        my $res = request( HTTP::Request->new( uc( $method ), $uri, $header, $content ) );

        my $ref;
        if ( $res->is_success && $res->content ) {
            $ref = $json->decode( $res->content );
        }

        return ( $res, $ref );
    }
}

done_testing();
