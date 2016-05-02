package Todo::Backend;

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Catalyst qw(
  ConfigLoader
);
use CatalystX::RoleApplicator;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->apply_request_class_roles( qw(Todo::Backend::TraitFor::Request::JSON) );

# Configure the application.
#
# Note that settings in todo_backend.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name                                        => 'Todo::Backend',
    disable_component_resolution_regex_fallback => 1,
    default_view                                => 'JSON',
    default_model                               => 'Todo',
    'Model::Todo'                               => {
        args => {
            database => $ENV{TODO_DATABASE} || '/tmp/todo.db',
        },
    },
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

Todo::Backend - Catalyst based application

=head1 SYNOPSIS

    script/todo_backend_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Todo::Backend::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Roman Filippov

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
