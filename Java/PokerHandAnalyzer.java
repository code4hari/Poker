package fivecardstud.Java;
import java.io.*;
import java.util.*;

public class PokerHandAnalyzer {
    static String[] ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };
    static String[] suits = { "D", "C", "H", "S" };

    static Map<String, Integer> handRankings = Map.of(
            "Royal Straight Flush", 10,
            "Straight Flush", 9,
            "Four of a Kind", 8,
            "Full House", 7,
            "Flush", 6,
            "Straight", 5,
            "Three of a Kind", 4,
            "Two Pair", 3,
            "Pair", 2,
            "High Card", 1
    );

    public static class Card {
        String rank;
        String suit;

        public Card(String rank, String suit) {
            this.rank = rank;
            this.suit = suit;
        }

        @Override
        public String toString() {
            return rank + suit;
        }
    }

    public static class Hand {
        List<Card> cards;

        public Hand(List<Card> cards) {
            this.cards = cards;
        }

        @Override
        public String toString() {
            StringBuilder sb = new StringBuilder();
            for (Card card : cards) {
                sb.append(card).append(" ");
            }
            return sb.toString().trim();
        }

        public String evaluateRank() {
            Map<String, Integer> counts = new HashMap<>();
            for (Card card : cards) {
                counts.put(card.rank, counts.getOrDefault(card.rank, 0) + 1);
            }

            boolean isStraight = counts.size() == 5 &&
                    getMaxRankIndex() - getMinRankIndex() == 4;

            boolean isFlush = cards.stream().map(c -> c.suit).distinct().count() == 1;

            if (isStraight && isFlush) {
                if (counts.keySet().containsAll(Arrays.asList("A", "10", "J", "Q", "K"))) {
                    return "Royal Straight Flush";
                }
                return "Straight Flush";
            } else if (counts.containsValue(4)) {
                return "Four of a Kind";
            } else if (counts.containsValue(3) && counts.containsValue(2)) {
                return "Full House";
            } else if (isFlush) {
                return "Flush";
            } else if (isStraight) {
                return "Straight";
            } else if (counts.containsValue(3)) {
                return "Three of a Kind";
            } else if (Collections.frequency(counts.values(), 2) == 2) {
                return "Two Pair";
            } else if (counts.containsValue(2)) {
                return "Pair";
            } else {
                return "High Card";
            }
        }

        public String evaluateSuit() {
            Map<String, Integer> suitCounts = new HashMap<>();
            for (Card card : cards) {
                suitCounts.put(card.suit, suitCounts.getOrDefault(card.suit, 0) + 1);
            }
            return suitCounts.entrySet().stream()
                    .max(Comparator.comparingInt(Map.Entry::getValue))
                    .get().getKey();
        }

        public int compare(Hand other) {
            String rank1 = this.evaluateRank();
            String rank2 = other.evaluateRank();

            if (handRankings.get(rank1) > handRankings.get(rank2)) {
                return 1;
            } else if (handRankings.get(rank1) < handRankings.get(rank2)) {
                return -1;
            } else {
                return 0;  
            }
        }

        private int getMaxRankIndex() {
            return cards.stream().mapToInt(c -> Arrays.asList(ranks).indexOf(c.rank)).max().getAsInt();
        }

        private int getMinRankIndex() {
            return cards.stream().mapToInt(c -> Arrays.asList(ranks).indexOf(c.rank)).min().getAsInt();
        }
    }

    public static List<Card> createDeck() {
        List<Card> deck = new ArrayList<>();
        for (String rank : ranks) {
            for (String suit : suits) {
                deck.add(new Card(rank, suit));
            }
        }
        Collections.shuffle(deck);
        return deck;
    }

    public static List<Hand> dealHands(List<Card> deck, int numHands) {
        List<Hand> hands = new ArrayList<>();
        for (int i = 0; i < numHands; i++) {
            List<Card> handCards = new ArrayList<>();
            for (int j = 0; j < 5; j++) {
                handCards.add(deck.remove(0));
            }
            hands.add(new Hand(handCards));
        }
        return hands;
    }

    public static void printResults(List<Hand> hands) {
        for (int i = 0; i < hands.size(); i++) {
            Hand hand = hands.get(i);
            String rank = hand.evaluateRank();
            System.out.printf("Hand %d: %s - %s%n", i + 1, hand, rank);
        }
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            List<Card> deck = createDeck();
            System.out.println("*** P O K E R H A N D A N A L Y Z E R ***");
            System.out.println("*** USING RANDOMIZED DECK OF CARDS ***");
            System.out.println("*** Shuffled 52 card deck:");
            deck.forEach(card -> System.out.print(card + " "));
            System.out.println("\n*** Here are the six hands...");
            List<Hand> hands = dealHands(new ArrayList<>(deck), 6);
            for (int i = 0; i < hands.size(); i++) {
                System.out.printf("Hand %d: %s%n", i + 1, hands.get(i));
            }
            System.out.println("--- WINNING HAND ORDER ---");
            hands.sort((h1, h2) -> h2.compare(h1));
            printResults(hands);
        } else {
            String filename = args[0];
            System.out.println("*** P O K E R H A N D A N A L Y Z E R ***");
            System.out.println("*** USING TEST DECK ***");
            System.out.println("*** File: " + filename);
            try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
                List<Hand> hands = new ArrayList<>();
                String line;
                while ((line = br.readLine()) != null) {
                    List<Card> cards = new ArrayList<>();
                    String[] cardStrings = line.split(", ");
                    for (String cardStr : cardStrings) {
                        cards.add(new Card(cardStr.substring(0, cardStr.length() - 1),
                                cardStr.substring(cardStr.length() - 1)));
                    }
                    hands.add(new Hand(cards));
                }
                System.out.println("*** Here are the six hands...");
                for (int i = 0; i < hands.size(); i++) {
                    System.out.printf("Hand %d: %s%n", i + 1, hands.get(i));
                }
                System.out.println("--- WINNING HAND ORDER ---");
                hands.sort((h1, h2) -> h2.compare(h1));
                printResults(hands);
            } catch (IOException e) {
                System.err.println("Error reading file: " + e.getMessage());
            }
        }
    }
}
