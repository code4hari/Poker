#!/usr/bin/perl

use strict;
use warnings;

# Card class
package Card;

sub new {
    my ($class, $face, $suit) = @_;
    my $self = {
        face => $face,
        suit => $suit,
    };
    bless $self, $class;
    return $self;
}

sub getFace {
    my ($self) = @_;
    return $self->{face};
}

sub getSuit {
    my ($self) = @_;
    return $self->{suit};
}

sub toString {
    my ($self) = @_;
    return $self->{face} . $self->{suit};
}

# Main program
package main;

my @faces = ('2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A');
my @suits = ('D', 'C', 'H', 'S');

my @deck = ();
foreach my $face (@faces) {
    foreach my $suit (@suits) {
        push @deck, Card->new($face, $suit);
    }
}

if (@ARGV == 0) {
    print "*** P O K E R H A N D A N A L Y Z E R ***\n";
    print "*** USING RANDOMIZED DECK OF CARDS ***\n";
    
    # Shuffle the deck
    fisher_yates_shuffle(\@deck);
    
    print "*** Shuffled 52 card deck:\n";
    printDeck(@deck);
    
    print "*** Here are the six hands...\n";
    my @hands = dealHands(\@deck, 6, 5);
    foreach my $hand (@hands) {
        printHand(@$hand);
    }
    
    print "*** Here is what remains in the deck...\n";
    printDeck(@deck);
    
    print "--- WINNING HAND ORDER ---\n";
    my @sortedHands = sortHands(@hands);
    foreach my $hand (@sortedHands) {
        printHand(@$hand);
        print " - " . evaluateHand(@$hand) . "\n";
    }
}
else {
    my $filename = $ARGV[0];
    print "*** P O K E R H A N D A N A L Y Z E R ***\n";
    print "*** USING TEST DECK ***\n";
    print "*** File: $filename\n";
    
    open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";
    my @hands = ();
    while (my $line = <$fh>) {
        chomp $line;
        print "$line\n";
        my @cards = split(/,\s*/, $line);
        my @hand = ();
        foreach my $card (@cards) {
            $card =~ s/\s+//g;
            my $face = substr($card, 0, length($card) - 1);
            my $suit = substr($card, -1);
            push @hand, Card->new($face, $suit);
        }
        push @hands, \@hand;
    }
    close $fh;
    
    print "*** Here are the six hands...\n";
    foreach my $hand (@hands) {
        printHand(@$hand);
    }
    
    print "--- WINNING HAND ORDER ---\n";
    my @sortedHands = sortHands(@hands);
    foreach my $hand (@sortedHands) {
        printHand(@$hand);
        print " - " . evaluateHand(@$hand) . "\n";
    }
}

sub fisher_yates_shuffle {
    my ($array) = @_;
    for (my $i = @$array - 1; $i > 0; $i--) {
        my $j = int(rand($i + 1));
        @$array[$i, $j] = @$array[$j, $i];
    }
}

sub dealHands {
    my ($deck, $numHands, $cardsPerHand) = @_;
    my @hands = ();
    for (my $i = 0; $i < $numHands; $i++) {
        my @hand = ();
        for (my $j = 0; $j < $cardsPerHand; $j++) {
            push @hand, shift @$deck;
        }
        push @hands, \@hand;
    }
    return @hands;
}

sub printDeck {
    my (@deck) = @_;
    my $count = 0;
    foreach my $card (@deck) {
        print $card->toString() . " ";
        $count++;
        if ($count % 13 == 0) {
            print "\n";
        }
    }
    print "\n";
}

sub printHand {
    my (@hand) = @_;
    foreach my $card (@hand) {
        print $card->toString() . " ";
    }
    print "\n";
}

sub evaluateHand {
    my (@hand) = @_;
    
    my %faces = ();
    my %suits = ();
    foreach my $card (@hand) {
        $faces{$card->getFace()}++;
        $suits{$card->getSuit()}++;
    }
    
    my @uniqueFaces = keys %faces;
    my @uniqueSuits = keys %suits;
    
    my $isFlush = scalar @uniqueSuits == 1;
    my $isStraight = 0;
    if (scalar @uniqueFaces == 5) {
        my @sortedFaces = sort { $faces{$a} <=> $faces{$b} } @uniqueFaces;
        $isStraight = 1;
        for (my $i = 1; $i < 5; $i++) {
            if ($faces{$sortedFaces[$i]} != $faces{$sortedFaces[$i-1]} + 1) {
                $isStraight = 0;
                last;
            }
        }
        if (!$isStraight && $sortedFaces[0] eq 'A' && $sortedFaces[1] eq '2' && $sortedFaces[2] eq '3' && $sortedFaces[3] eq '4' && $sortedFaces[4] eq '5') {
            $isStraight = 1;
        }
    }
    
    if ($isFlush && $isStraight) {
        my @sortedFaces = sort { $faces{$a} <=> $faces{$b} } @uniqueFaces;
        if ($sortedFaces[0] eq '10' && $sortedFaces[4] eq 'A') {
            return "Royal Straight Flush";
        }
        else {
            return "Straight Flush";
        }
    }
    elsif (scalar @uniqueFaces == 2) {
        my @faceCount = sort { $faces{$b} <=> $faces{$a} } @uniqueFaces;
        if ($faces{$faceCount[0]} == 4) {
            return "Four of a Kind";
        }
        else {
            return "Full House";
        }
    }
    elsif ($isFlush) {
        return "Flush";
    }
    elsif ($isStraight) {
        return "Straight";
    }
    elsif (scalar @uniqueFaces == 3) {
        my @faceCount = sort { $faces{$b} <=> $faces{$a} } @uniqueFaces;
        if ($faces{$faceCount[0]} == 3) {
            return "Three of a Kind";
        }
        else {
            return "Two Pair";
        }
    }
    elsif (scalar @uniqueFaces == 4) {
        return "Pair";
    }
    else {
        return "High Card";
    }
}

sub sortHands {
    my (@hands) = @_;
    
    my @sortedHands = sort {
        my $rankA = getRank(evaluateHand(@$a));
        my $rankB = getRank(evaluateHand(@$b));
        
        if ($rankA == $rankB) {
            my @sortedA = sort { $b->getFace() cmp $a->getFace() } @$a;
            my @sortedB = sort { $b->getFace() cmp $a->getFace() } @$b;
            
            for (my $i = 0; $i < 5; $i++) {
                if ($sortedA[$i]->getFace() ne $sortedB[$i]->getFace()) {
                    return $sortedB[$i]->getFace() cmp $sortedA[$i]->getFace();
                }
                elsif ($sortedA[$i]->getSuit() ne $sortedB[$i]->getSuit()) {
                    return $sortedB[$i]->getSuit() cmp $sortedA[$i]->getSuit();
                }
            }
            
            return 0;
        }
        else {
            return $rankB <=> $rankA;
        }
    } @hands;
    
    return @sortedHands;
}

sub getRank {
    my ($handType) = @_;
    
    my %ranks = (
        "Royal Straight Flush" => 10,
        "Straight Flush" => 9,
        "Four of a Kind" => 8,
        "Full House" => 7,
        "Flush" => 6,
        "Straight" => 5,
        "Three of a Kind" => 4,
        "Two Pair" => 3,
        "Pair" => 2,
        "High Card" => 1,
    );
    
    return $ranks{$handType};
}