package Crawl::Bot::Plugin::JoinAfterAuth;
use Moose;
extends 'Crawl::Bot::Plugin';

sub is_nickserv_auth_ack {
    my $m = shift;
    $m->{channel} eq 'msg'
        && $m->{who} eq 'NickServ'
        && $m->{raw_nick} =~ /NickServ!NickServ/
        && $m->{body} =~ /You are now identified for/
}

sub join_all_channels {
    my $self = shift;
    for my $channel (@{$self->bot->{channels}}) {
        print STDERR "/join $channel\n";
        $self->bot->pocoirc->yield('join', $channel);
    }
}

sub said {
    my ($self, $m) = @_;
    if (is_nickserv_auth_ack($m)) {
        print STDERR "authenticated; joining all channels at " . localtime() . "\n";
        $self->join_all_channels();
    }
    return undef;
}

1;
