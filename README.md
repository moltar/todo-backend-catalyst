# Todo Backend - Perl [Catalyst](https://metacpan.org/pod/Catalyst) Implementation

[![Build Status](https://travis-ci.org/moltar/todo-backend-catalyst.png?branch=master)](https://travis-ci.org/moltar/todo-backend-catalyst)

This is a very basic Catalyst implementation of the [TODO backend](http://www.todobackend.com/).

One interesting module is the [Plack::Middleware::CrossOrigin](https://metacpan.org/pod/Plack::Middleware::CrossOrigin) but everything else is relatively standard.

Feel free to submit pull requests to improve this.

[Run live test on todobackend.com](http://www.todobackend.com/specs/index.html?https://todo-backend-catalyst.herokuapp.com/)

## Heroku

This repo is Heroku-ready via [Heroku buildpack: Perl](https://github.com/miyagawa/heroku-buildpack-perl.git).
Follow the instructions on the repo to launch it.

Live demo can be found here: [https://todo-backend-catalyst.herokuapp.com/](https://todo-backend-catalyst.herokuapp.com/).

## Carton

To get started locally, you can use [Carton](https://metacpan.org/pod/Carton) to install the dependencies.

```sh
carton install
carton exec -- plackup app.psgi
```
