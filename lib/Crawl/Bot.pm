package Crawl::Bot;
use Moose;
use MooseX::NonMoose;
extends 'Bot::BasicBot';

use File::Path;
use Module::Pluggable (
    instantiate => 'new',
    sub_name    => 'create_plugins',
);

has [qw(username name)] => (
    # don't need (or want) accessors, just want to initialize the hash slot
    # for B::BB to use
    is      => 'bare',
    isa     => 'Str',
    default => sub { shift->nick },
);

has data_dir => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        return File::Spec->rel2abs('dat');
    },
);

has update_time => (
    is      => 'ro',
    isa     => 'Int',
    default => 5,
);

has force_update_frequency => (
    is      => 'ro',
    isa     => 'Int',
    default => 60,  # Measured in ticks
);

has plugins => (
    is      => 'ro',
    isa     => 'ArrayRef[Crawl::Bot::Plugin]',
    lazy    => 1,
    default => sub { [__PACKAGE__->create_plugins(bot => shift)] },
);

has max_length => (
    is      => 'ro',
    isa     => 'Int',
    default => 410
);

sub connected {
  my $self = shift;

  open(my $handle, '<', '.password') or warn "Unable to read .password: $!" and return undef;
  my $password = <$handle>;
  chomp $password;

  $self->say(channel => 'msg',
             who     => 'nickserv',
             body    => "identify $password");

  return undef;
}

sub BUILD {
    my $self = shift;
    File::Path::mkpath($self->data_dir);
    $self->plugins;
}

around say => sub {
    my $next = shift;
    my ($self, %params) = @_;
#    # don't talk in main channels unless we're the real thing
#    if ($self->nick ne "Cheibriados" &&
#                ($params{channel} eq "##crawl-dev"
#	 || $params{channel} eq "##crawl"))
#    {
#        return undef;
#    }
    print STDERR "sending '$params{body}' to $params{channel}\n";
    $_->sent({%params, who => $self->nick}) for @{ $self->plugins };
    $next->($self, %params);
};

my $tickcount = 0;
sub tick {
    my $self = shift;
    my $pokefile = File::Spec->catfile($self->data_dir, "poke");

    if (++$tickcount < $self->force_update_frequency and ! -f $pokefile) {
        return $self->update_time;
    } else {
        $tickcount = 0;
        -f $pokefile and unlink $pokefile;
    }

    print STDERR "Checking for updates at " . localtime() . ":\n";
    for (@{ $self->plugins }) {
        print STDERR " --- " . ref($_);

        my $before = time;
        $_->tick;
        printf STDERR " [%d sec]\n", time - $before
    }
    print STDERR "Done\n";
    return $self->update_time;
}

for my $meth (qw(said         emoted   chanjoin  chanpart
                 nick_change  kicked   topic     userquit)) {
    __PACKAGE__->meta->add_method($meth => sub {
        my $self = shift;
        $_->$meth(@_) for @{ $self->plugins };
        undef;
    });
}

sub say_all {
    my $self = shift;
    my ($message) = @_;
    $self->say(
        channel => $_,
        body    => $message,
    ) for $self->channels;
}

sub say_main {
    my $self = shift;
    my ($message) = @_;
    $self->say(
        channel => ($self->channels)[0],
        body    => $message,
    );
}

1;
