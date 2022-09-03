package Crawl::Bot::Plugin::Help;
use Moose;
use autodie;
extends 'Crawl::Bot::Plugin';

sub said {
    my $self = shift;
    my ($args) = @_;

    my @keys = (who => $args->{who}, channel => $args->{channel}, "body");

    if ($args->{body} =~ /^\%help(?:\s+(.*))?$/) {
	$self->say(@keys, 'This bot reports Git activity in XMonad repos. It has only two commands:');
	$self->say(@keys, ' %git(core|contrib|extras|X11|X11-xft|all) [revspec]');
	$self->say(@keys, ' %help');
    }
}

sub tick {
    # we do nothing except respond to help requests
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
