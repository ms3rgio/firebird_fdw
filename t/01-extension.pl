#!/usr/bin/env perl

# 01-extension.pl
#
# Basic sanity check to ensure the extension is installed
#
# Creates a single table on the Firebird server, a corresponding
# foreign table in PostgreSQL and performs some simple DML

use strict;
use warnings;

use Cwd;
use Config;
use TestLib;
use Test::More tests => 4;


use FirebirdFDWNode;
use FirebirdFDWDB;

# Initialize PostgreSQL node
# --------------------------

my $pg_node = get_new_fdw_node('pg_node');

$pg_node->init();
$pg_node->start();

my $pg_db = FirebirdFDWDB->new($pg_node);

# 1. Check version
# ----------------
#
# TODO: parse the value from "firebird_fdw.control" and check for a match

my $version = '500';

my $res = $pg_db->safe_psql(q|SELECT firebird_fdw_version()|);

is(
	$res,
	$version,
	'version OK',
);



# Prepare table
# --------------

my $table_name = $pg_db->init_table();

# 2. Insert a row
# ---------------

my $insert_q = sprintf(
    q|INSERT INTO %s (lang_id, name_english, name_native) VALUES('en', 'English', 'English')|,
    $table_name,
);

$pg_db->safe_psql( $insert_q );

# Check it arrives

my $queryText = sprintf(
    q|SELECT name_english FROM %s WHERE lang_id = 'en'|,
    $table_name,
);

my $query = $pg_node->{dbh}->prepare($queryText);

$query->execute();

$res = $query->fetchrow_array();

$query->finish();

is(
	$res,
	'English',
	'insert OK',
);


# 3. Update the row
# -----------------

my $update_q = sprintf(
    q|UPDATE %s SET name_native = 'Wibblish' WHERE lang_id = 'en'|,
    $table_name,
);

$pg_db->safe_psql( $update_q );

$queryText = sprintf(
    q|SELECT name_native FROM %s WHERE lang_id = 'en'|,
    $table_name,
);

$query = $pg_node->{dbh}->prepare($queryText);

$query->execute();

$res = $query->fetchrow_array();

$query->finish();

is(
	$res,
	'Wibblish',
	'update OK',
);


# 4. Delete the row
# -----------------

my $delete_q = sprintf(
    q|DELETE FROM %s WHERE lang_id = 'en'|,
    $table_name,
);

$pg_db->safe_psql( $delete_q );

$queryText = sprintf(
    q|SELECT COUNT(*) FROM %s WHERE lang_id = 'en'|,
    $table_name,
);

$query = $pg_node->{dbh}->prepare($queryText);

$query->execute();

$res = $query->fetchrow_array();

$query->finish();

is(
	$res,
	'0',
	'delete OK',
);


# Clean up
# --------

$pg_db->drop_foreign_server();
$pg_node->drop_table($table_name);

done_testing();
