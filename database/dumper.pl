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
    my $dir = $p{dir};
    my $database = $p{database};
    my $version = $p{version};
    my $name = $p{name};
    my $credentials = make_credentials(%p);

    $version = $name if not defined $version;

    print "Dumping database $database, version $version.\n";
    system("mysqldump $credentials $database --no-data " .
           "> $dir/schema-$version.sql") == 0
      or die "Error dumping schema: " . ($? >> 8) . "\n";

    print "Dumping data only.\n";
    system("mysqldump $credentials $database > $dir/data-$version.sql") == 0
      or die "Error dumping data only: " . ($? >> 8) . "\n";

    print "Dumping full database.\n";
    system("mysqldump $credentials --databases $database " . 
           "> $dir/full-$version.sql") == 0
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

sub migrate_database_versions {
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

sub migrate_database_name {
    my %p = @_;
    my $database = $p{database};
    my $name = $p{name};
    my $credentials = make_credentials(%p);
    my $root = make_credentials(user => 'root', password => $p{root_password});

    foreach my $script (sort(glob("migrate-$name-*.sql"))) {
        print "Migrating $database using $script.\n";
        system("mysql $credentials $database < $script") == 0
          or die "Error migrating using $script:" . ($? >> 8) . "\n";
    }
}

sub migrate_database_scripts {
    my %p = @_;
    my $database = $p{database};
    my $scripts = $p{scripts};
    my $credentials = make_credentials(%p);
    my $root = make_credentials(user => 'root', password => $p{root_password});

    foreach my $script (@$scripts) {
        print "Migrating $database using $script.\n";
        system("mysql $credentials $database < $script") == 0
          or die "Error migrating using $script:" . ($? >> 8) . "\n";
    }
}

sub make_scratch_database {
    my %p = @_;
    my $database = $p{database};
    my $user = $p{user};
    my $password  = $p{password};
    my $root = make_credentials(user => 'root', password => $p{root_password});

    # Prevent ourselves from nuking our main databases!
    die "Scratch database cannot be named gcdonline!"
      if $database =~ /^gcdonline$/i;
    die "Scratch database cannot be named gcd_dev!"
      if $database =~ /^gcd_dev$/i;

    my $password_statement = $password ?
                             "IDENTIFIED BY '$password'" :
                             '';
    my $command = <<EOC;
mysql $root <<EOD
DROP DATABASE IF EXISTS $database;
CREATE DATABASE $database DEFAULT CHARACTER SET utf8;
GRANT ALL ON $database.* TO '$user'\@'localhost' $password_statement;
EOD
EOC

    print "Creating database $database.\n";
    system($command) == 0
      or die "Could not create $database: " . ($? >> 8) . "\n";
}

sub dump_replication_to_scratch {
    my %p = @_;
    my $dir = $p{dir};
    my $database = $p{database};
    my $password  = $p{password};
    my $credentials = make_credentials(%p);
    my $root = make_credentials(user => 'root', password => $p{root_password});

    print "Dumping the replication database.\n";

    my $tables = "countries covers indexcredit indexers issues languages " .
                 "publishers reservations series stories";
    system("mysqldump $root gcdonline $tables > $dir/raw.sql") == 0
      or die "Could not make raw dump of gcdonline.: " . ($? >> 8) . "\n";
    print "Loading the data into $database.\n";
    system("mysql $credentials $database < $dir/raw.sql") == 0
      or die "Could not load the data into $database: " . ($? >> 8) . "\n";
}

sub load_to_scratch {
    my %p = @_;
    my $database = $p{database};
    my $dumpfile = $p{dumpfile};
    my $password  = $p{password};
    my $credentials = make_credentials(%p);

    print "Loading file $dumpfile into $database.\n";
    system("mysql $credentials $database < $dumpfile") == 0
      or die "Could not load the data into $database: " . ($? >> 8) . "\n";
}

sub main {
    my $version;
    my $name;
    my $root_password;
    my $dump_only;
    my @load_only = ();
    my $database = 'gcd_scratch';
    my @scripts = ();
    my $dir = ".";
    my $help = 0;

    GetOptions("version=i" => \$version,
               "name=s" => \$name,
               "database=s" => \$database,
               "password=s" => \$root_password,
               "dump-only" => \$dump_only,
               "load-only=s" => \@load_only,
               "script=s" => \@scripts,
               "dir=s" => \$dir,
               "help|?" => \$help)
      or pod2usage(2);

    pod2usage(-exitstatus => 0, -verbose => 2) if $help;
    pod2usage(2) unless (defined $version or @scripts or defined $name);

    my %args = (
        database => $database,
        user => 'gcd_dumper',
        dir => $dir,
    );
    $args{root_password} = $root_password if defined $root_password;

    unless ($dump_only) {
        make_scratch_database(%args);
        if (@load_only) {
            foreach my $load_script (@load_only) {
                load_to_scratch(%args, dumpfile => $load_script);
            }
        } else {
            dump_replication_to_scratch(%args);
            scrub_database(%args);
            make_dumps(%args, version => 0);
        }
        if (defined $version) {
            migrate_database_versions(%args, version => $version);
        } elsif (defined $name) {
            migrate_database_name(%args, name => $name);
        } else {
            migrate_database_scripts(%args, scripts => \@scripts);
        }
    }
    unless (@load_only) {
        make_dumps(%args, version => $version, name => $name);
    }
}

main();

__END__

=head1 NAME

dump.pl - Dumps the replicated database into our standard formats.

=head1 SYNOPSIS

dump.pl --version=version-number [options]
dump.pl --name=version-name [options]
dump.pl --script=first-script.sql --script=second-script.sql ... [options]

  Options:
    The version, name and script options are mutually exclusive.

    --help        Prints usage
    --version     Migrate to a specific version just based on numbers.
    --name        Migrate to a named schema version, possibly using multiple
                  scripts in oder.
    --script      Add a script to run as migration, can be used many times
                  to run arbitrary scripts in order.
    --database    Name for scratch database.  Defaults to gcd_scratch.
    --password    Root password for the mysql installation.
    --dir         Directory where dumps should be placed.  The default is
                  the current directory.
    --dump-only   Just dump the given scratch database as the given version.
                  This option does not pull new data from the replication
                  database or do any migrations.  The scratch database
                  must already exist and be in the correct schema version.
    --load-only   Load an existing dump and migrate it without dumping further.
                  Can be specified multiple times if there are several files
                  to load before the migration should start.

