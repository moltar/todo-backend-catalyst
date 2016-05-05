requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Runtime';
requires 'Catalyst::View::JSON';
requires 'Config::General';
requires 'DBM::Deep';
requires 'Plack::Middleware::CrossOrigin';
requires 'UUID::Tiny';

on 'develop' => sub {
    requires 'Catalyst::Devel';
    requires 'Term::Size::Any';
};
