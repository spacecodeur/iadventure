#!/usr/bin/perl
use strict;
use warnings;

sub count_capture_groups {
    my ($pattern) = @_;
    my $count = 0;
    # Compte les parenthèses non échappées qui ne sont pas (?: ...)
    while ($pattern =~ /(?<!\\)\((?!\?[:=!])/g) {
        $count++;
    }
    return $count;
}

sub match_regex_multiline {
    my ($text, $pattern) = @_;

    # my $group_count = count_capture_groups($pattern);
    # if ($group_count != 1) {
    #     die "ERREUR: La regex doit contenir exactement 1 groupe de capture (trouvé $group_count)";
    # }

    # Split le texte en lignes pour garder le numéro de ligne
    my @lines = split(/\n/, $text);

    # Essaie de matcher le pattern sur le texte complet
    if ($text =~ qr/$pattern/s) {
        my $full_match = $&;
        my $captured = $1 // '';
        
        if ($captured eq '') {
            # Cas où la capture est vide
            my $before_match_end = substr($text, 0, $+[0]);
            my @before_match_end_lines = split(/\n/, $before_match_end);
            my $start_line = scalar(@before_match_end_lines);
            
            # Calcul de la position dans la ligne
            my $last_newline_pos = rindex($before_match_end, "\n");
            my $char_pos = $last_newline_pos == -1 
                        ? length($before_match_end)
                        : (length($before_match_end) - $last_newline_pos - 1);
            
            return ($start_line, $char_pos, 1, '');
        }
        else {
            # Cas normal avec capture non vide
            my $before_capture = substr($text, 0, $-[1]);
            my @before_capture_lines = split(/\n/, $before_capture);
            my $start_line = scalar(@before_capture_lines) + 1;
            
            # Calcul de la position dans la ligne
            my $last_newline_pos = rindex($before_capture, "\n");
            my $char_pos = $last_newline_pos == -1 
                        ? length($before_capture)
                        : ($-[1] - $last_newline_pos - 1);
            
            my @captured_lines = split(/\n/, $captured);
            my $lines_matched = scalar(@captured_lines);
            
            return ($start_line, $char_pos, $lines_matched, $captured);
        }
    }
    return ();  # pas de match
}

# Lire soit depuis un fichier, soit depuis STDIN
my ($textfile, $pattern) = @ARGV;
my $text;

if ($textfile) {
    open my $fh, '<', $textfile or die "Impossible d'ouvrir $textfile: $!";
    $text = do { local $/; <$fh> };  # Slurp mode (tout d'un coup)
    close $fh;
} else {
    $text = do { local $/; <> };  # Lecture depuis STDIN
}

my ($start_line, $char_pos, $lines_matched, $captured) = match_regex_multiline($text, $pattern);



# Output formaté pour le bash
if (defined $start_line) {
    print "=== Captured group ===\n$captured\n";
    print "=== Start line ===\n$start_line\n";
    print "=== Line count ===\n$lines_matched\n";
    print "=== char pos ===\n$char_pos\n";
    exit 0;
} else {
    exit 1;  # Aucun match
}