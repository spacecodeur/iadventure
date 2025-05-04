#!/usr/bin/env perl
use strict;
use warnings;

# Vérification des arguments
if (@ARGV != 2) {
    die "Usage: $0 <fichier> <regex>\n";
}

my ($filename, $regex) = @ARGV;

# Lecture du fichier entier
open(my $fh, '<', $filename) or die "Impossible d'ouvrir le fichier '$filename': $!";
local $/ = undef;  # Lecture en une seule fois (multilignes)
my $content = <$fh>;
close($fh);

# Initialisation
my $match_count = 0;
my $first_line = -1;
my $first_capture = "";

# Recherche des correspondances avec regex greedy (par défaut en Perl)
while ($content =~ /$regex/g) {
    $match_count++;
    if ($match_count == 1) {
        $first_capture = $1 // '';
        # Calcul de la ligne correspondante
        my $match_pos = $-[0];  # position du début du match
        my $before_match = substr($content, 0, $match_pos);
        $first_line = () = $before_match =~ /\n/g;  # compte les \n avant
        $first_line++;  # car lignes commencent à 1
    }
}

# Affichage des résultats (séparés par tabulation)
print "$first_capture|||$first_line|||$match_count\n";
    