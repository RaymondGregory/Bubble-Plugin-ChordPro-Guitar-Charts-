#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::More tests => 4;

use App::Packager ( ':name', 'App::Music::ChordPro' );
use App::Music::ChordPro::Config;
use App::Music::ChordPro::Songbook;

# For transcoding, both source and target notation systems must be
# defined. The source system must be last, so it is current and used
# to parse the the input data.

our $config =
  eval {
      App::Music::ChordPro::Config::configurator
	  ( { nosysconfig => 1, nolegacyconfig => 1, nouserconfig => 1,
	      config => [ getresource("config/notes_latin.json"),
			  getresource("config/notes_dutch.json") ],
	    } );
  };
ok( $config, "got config" );
my $s = App::Music::ChordPro::Songbook->new;

my $data = <<EOD;
{title: Swing Low Sweet Chariot}
{key: D}
I [D]looked over Jordan, and [Gm7]what did I [D]see,
EOD

eval { $s->parsefile( \$data, { transcode => "latin" } ) } or diag("$@");

ok( scalar( @{ $s->{songs} } ) == 1, "One song" );
isa_ok( $s->{songs}->[0], 'App::Music::ChordPro::Song', "It's a song" );

my $song = {
	    'settings' => {},
	    'meta' => {
		       'key' => [ 'Re' ],
		       'title' => [
				   'Swing Low Sweet Chariot'
				  ],
		      },
	    'title' => 'Swing Low Sweet Chariot',
	    'chords' => {
			 'origin' => 'song',
			 'type' => 'diagrams',
			 'show' => 'all',
			 'chords' => [
				      'Re',
				      'Solm7'
				     ]
			},
	    'body' => [
                       {
			 'context' => '',
			 'phrases' => [
					'I ',
					'looked over Jordan, and ',
					'what did I ',
					'see,'
				      ],
			 'chords' => [
				       '',
				       'Re',
				       'Solm7',
				       'Re'
				     ],
			 'type' => 'songline'
		       }
		      ],
	    'source' => { file => "__STRING__", line => 1 },
	    'structure' => 'linear',
	   };

is_deeply( { %{ $s->{songs}->[0] } }, $song, "Song contents" );