package Todo::Backend::Controller::Root;

use Moose;
use HTTP::Status qw(HTTP_NOT_FOUND HTTP_CREATED HTTP_NO_CONTENT);
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=encoding utf-8

=head1 NAME

Todo::Backend::Controller::Root - Controller for Todo::Backend

=head1 DESCRIPTION

A controller for managing a todo list.

=head1 METHODS

=cut

=head2 base

Base method for all actions in the current controller. All of the actions are
chaining off of this one.

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

=head2 list_items

Returns a list of todos.

=cut

sub list_items : Chained('base') PathPart('') Args(0) GET {
    my ( $self, $c ) = @_;

    $c->res->json( $c->model->list );
}

=head2 clear_list

Remove all items from the todo list.

=cut

sub clear_list : Chained('base') PathPart('') Args(0) DELETE {
    my ( $self, $c ) = @_;

    $c->model->clear;
    $c->res->json( [] );
}

=head2 get_item

Get a single todo item given item ID.

=cut

sub get_item : Chained('base') PathPart('') Args(1) GET {
    my ( $self, $c, $item_id ) = @_;

    if ( my $item = $c->model->get( $item_id ) ) {
        $c->res->json( $item );
    }
    else {
        $c->res->status( HTTP_NOT_FOUND );
    }
}

=head2 create_item

Create a new todo item.

=cut

sub create_item : Chained('base') PathPart('') Args(0) POST {
    my ( $self, $c ) = @_;

    $c->res->json( $c->model->add( $c->req->json ) );
    $c->res->status( HTTP_CREATED );
}

=head2 delete_item

Delete a todo item given an item ID.

=cut

sub delete_item : Chained('base') PathPart('') Args(1) DELETE {
    my ( $self, $c, $item_id ) = @_;

    $c->model->delete( $item_id );
    $c->res->status( HTTP_NO_CONTENT );
}

=head2 edit_item

Modify a todo item.

=cut

sub edit_item : Chained('base') PathPart('') Args(1) PATCH {
    my ( $self, $c, $item_id ) = @_;

    $c->res->json( $c->model->edit( $item_id, $c->req->json ) );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

Roman Filippov

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
