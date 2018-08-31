# Installation

You will need to install from CPAN:

 * Bot::BasicBot
 * File::pushd
 * XML::RAI
 * Module::Pluggable
 * POE::Component::SSLify (if you want to connect with SSL)

# Configuration

The repo is configured for the official Cheibriados bot. To change this:

 * Edit the channel names and nick in `bin/run`.
 * Edit the user names in `lib/Crawl/Bot/Plugin/Puppet.pm`.

To enable SSL on the bot's connection, make sure you choose the correct port,
and add `ssl => 1` to the list of properties in `bin/run`. For example:

    Crawl::Bot->new(
        server   => 'chat.freenode.net',
        port     => 6697,
        ssl      => 1,
        channels => ['##crawl-dev'],
        nick     => 'FakeCheibriados',
        name     => 'FakeCheibriados the Crawl Bot',
    )->run;

To use nickserv, put the password in plaintext in a file called `.password` in
the root directory of the repository. Needless to say, this is not a secure
way of storing passwords.

# Running

From the root directory of the repository, call `bin/run`.