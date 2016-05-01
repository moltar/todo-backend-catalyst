package Todo::Backend::Controller::Root;

use Moose;
use JSON::MaybeXS;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head2 json

=cut

has json => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_json',
);

sub _build_json {
    my $self = shift;

    return JSON::MaybeXS->new( utf8 => 1 );
}

=encoding utf-8

=head1 NAME

Todo::Backend::Controller::Root - Root Controller for Todo::Backend

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    ## quite an ugly hack to get JSON decoder to work for PATCH
    ## unfortunately body_data accessor only works for POST and PUT methods
    if ( $c->request->body ) {
        $c->stash->{params} = $c->req->data_handlers->{'application/json'}->( $c->request->body, $c->req );
    }
}

=head2 list_items

Returns a list of todos.

=cut

sub list_items : Chained('base') PathPart('') Args(0) GET {
    my ( $self, $c ) = @_;

    $c->stash->{json} = $c->model->list;
}

=head2 clear_list

Remove all items from the list.

=cut

sub clear_list : Chained('base') PathPart('') Args(0) DELETE {
    my ( $self, $c ) = @_;

    $c->model->clear;
    $c->stash->{json} = [];
}

=head2 get_item

Get a single todo item given item ID.

=cut

sub get_item : Chained('base') PathPart('') Args(1) GET {
    my ( $self, $c, $item_id ) = @_;

    $c->stash->{json} = $c->model->get( $item_id );
}

=head2 create_item

Create a new todo item.

=cut

sub create_item : Chained('base') PathPart('') Args(0) POST {
    my ( $self, $c ) = @_;

    $c->stash->{json} = $c->model->add( $c->stash->{params} );
}

=head2 delete_item

Delete a todo item given an item ID.

=cut

sub delete_item : Chained('base') PathPart('') Args(1) DELETE {
    my ( $self, $c, $item_id ) = @_;

    $c->model->delete( $item_id );
    $c->stash->{json} = [];
}

=head2 edit_item

Modify todo item.

=cut

sub edit_item : Chained('base') PathPart('') Args(1) PATCH {
    my ( $self, $c, $item_id ) = @_;

    $c->stash->{json} = $c->model->edit( $item_id, $c->stash->{params} );
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