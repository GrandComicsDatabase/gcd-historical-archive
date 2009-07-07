#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

sub make_credentials {
    my %p = @_;
    my $user = $p{user};
    my $password = $p{password};

    my $credentials = "-u$user";
    $credentials .= " -p$password" if defined $password;
    return $credentials;
}

sub make_dumps {
    my %p = @_;
    my $database = $p{database};
    my $version = $p{version};
    my $credentials = make_credentials(%p);

    print "Dumping database $database, version $version.\n";
    system("mysqldump $credentials $database --no-data " .
           "> schema-$version.sql") == 0
      or die "Error dumping schema: " . ($? >> 8) . "\n";

    print "Dumping data only.\n";
    system("mysqldump $credentials $database > data-$version.sql") == 0
      or die "Error dumping data only: " . ($? >> 8) . "\n";

    print "Dumping full database.\n";
    system("mysqldump $credentials --databases $database " . 
           "> full-$version.sql") == 0
      or die "Error dumping data with create statement: " . ($? >> 8) . "\n";
}

sub scrub_database {
    my %p = @_;
    my $database = $p{database};
    my $credentials = make_credentials(%p);

    print "Scrubbing database $database.\n";

    system("mysql $credentials $database < scrub.sql") == 0
      or die "Error scrubbing database $database: " . ($? >> 8) . "\n";
}

sub migrate_database {
    my %p = @_;
    my $database = $p{database};
    my $version = $p{version};
    my $credentials = make_credentials(%p);
    my $root = make_credentials(user => 'root', password => $p{root_password});

    foreach my $current (0 .. ($version - 1)) {
        my $next = $current + 1;

        print "Migrating $database from $current to $next.\n";
        system("mysql $credentials $database < migrate-$current-$next.sql") == 0
          or die "Error migrating from $current to $next:" . ($? >> 8) . "\n";

        if ($next == 2) {
            my $script = 'add-triggers-2.sql';
            print "Running post-migration script $script.\n";
            system("mysql $root $database < $script") == 0
              or die "Error running post-migration script $script: " .
                     ($? >> 8) . "\n";
        }
    }
}

sub make_scratch_database {
    my %p = @_;
    my $database = $p{database};
    my $user = $p{user};
    my $password  = $p{password};
    my $credentials = make_credentials(%p);
    my $root = make_credentials(user => 'root', password => $p{root_password});

    # Prevent ourselves from nuking our main database!
    die "Scratch database cannot be named gcdonline!"
      if $database =~ /^gcdonline$/i;

    my $password_statement = $password ?
                             "IDENTIFIED BY '$password'" :
                             '';
    my $command = <<EOC;
mysql -uroot <<EOD
CREATE DATABASE $database DEFAULT CHARACTER SET utf8;
GRANT ALL ON $database.* TO '$user'\@'localhost' $password_statement;
EOD
EOC

    print "Creating database $database.\n";
    system($command) == 0
      or die "Could not create $database: " . ($? >> 8) . "\n";
    print "Dumping the replication database.\n";

    my $tables = "countries covers indexcredit indexers issues languages " .
                 "publishers reservations series stories";
    system("mysqldump $root gcdonline $tables > raw.sql") == 0
      or die "Could not make raw dump of gcdonline.: " . ($? >> 8) . "\n";
    print "Loading the data into $database.\n";
    system("mysql $credentials $database < raw.sql") == 0
      or die "Could not load the data into $database: " . ($? >> 8) . "\n";
}

sub main {
    my $version;
    my $root_password;
    my $dump_only;
    my $database = 'gcd_scratch';
    my $help = 0;

    GetOptions("version=i" => \$version,
               "database=s" => \$database,
               "password=s" => \$root_password,
               "dump-only" => \$dump_only,
               "help|?" => \$help)
      or pod2usage(2);

    pod2usage(-exitstatus => 0, -verbose => 2) if $help;
    pod2usage(2) unless defined $version;

    my %args = (
        database => $database,
        user => 'gcd_dumper',
    );
    $args{root_password} = $root_password if defined $root_password;

    unless ($dump_only) {
        make_scratch_database(%args);
        scrub_database(%args);
        make_dumps(%args, version => 0);
        migrate_database(%args, version => $version);
    }
    make_dumps(%args, version => $version);
}

main();

__END__

=head1 NAME

dump.pl - Dumps the replicated database into our standard formats.

=head1 SYNOPSIS

dump.pl --version=version-number [options]

  Options:
    --help        Prints usage
    --version     Sets the schema version to which to migrate
    --database    Name for scratch database.  Defaults to gcd_scratch
    --password    Root password for the mysql installation
    --dump-only   Just dump the given scratch database as the given version.
                  This option does not pull new data from the replication
                  database or do any migrations.  The scratch database
                  must already exist and be in the correct schema version.

