#include <iostream>
#include <vector>
#include <algorithm>
#include <random>
#include <fstream>
#include <stdexcept>
#include <map>
#include <sstream>



enum class Suit { Diamonds, Clubs, Hearts, Spades };


enum class Rank {
    Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King
};


struct Card {
    Rank rank;
    Suit suit;

    friend std::ostream& operator<<(std::ostream& os, const Card& card) {
        static const std::string ranks[] = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};
        static const std::string suits[] = {"D", "C", "H", "S"};
        os << ranks[static_cast<int>(card.rank) - 1] << suits[static_cast<int>(card.suit)];
        return os;
    }
};


struct Hand {
    std::vector<Card> cards;

    friend std::ostream& operator<<(std::ostream& os, const Hand& hand) {
        for (const auto& card : hand.cards) {
            os << card << " ";
        }
        return os;
    }


    std::string evaluateRank() const {
        std::vector<int> counts(13, 0);
        for (const auto& card : cards) {
            counts[static_cast<int>(card.rank) - 1]++;
        }

        bool isStraight = true;
        for (int i = 0; i < 5; i++) {
            if (counts[i] != 1) {
                isStraight = false;
                break;
            }
        }

        if (isStraight) {
            if (counts[0] && counts[9] && counts[10] && counts[11] && counts[12]) {
                return "Royal Straight Flush";
            } else {
                return "Straight Flush";
            }
        }

        
        int pairCount = 0;
        int threeCount = 0;
        for (int count : counts) {
            if (count == 2) pairCount++;
            if (count == 3) threeCount++;
        }

        if (pairCount == 2) return "Two Pair";
        if (threeCount == 1) return "Three of a Kind";
        if (pairCount == 1) return "Pair";

       
        Suit suit = cards[0].suit;
        for (const auto& card : cards) {
            if (card.suit != suit) return "High Card";
        }
        return "Flush";
    }


    int compare(const Hand& other) const {
        static const std::map<std::string, int> handRankings = {
            {"Royal Straight Flush", 10}, {"Straight Flush", 9}, {"Four of a Kind", 8},
            {"Full House", 7}, {"Flush", 6}, {"Straight", 5}, {"Three of a Kind", 4},
            {"Two Pair", 3}, {"Pair", 2}, {"High Card", 1}
        };

        std::string rank1 = evaluateRank();
        std::string rank2 = other.evaluateRank();

        if (handRankings.at(rank1) > handRankings.at(rank2)) return 1;
        if (handRankings.at(rank1) < handRankings.at(rank2)) return -1;

        
        if (rank1 == "Flush" || rank1 == "Straight Flush" || rank1 == "Royal Straight Flush") {
            Suit suit1 = cards[0].suit;
            Suit suit2 = other.cards[0].suit;
            if (suit1 < suit2) return 1;
            if (suit1 > suit2) return -1;
        } else if (rank1 == "High Card") {
            for (int i = 0; i < 5; i++) {
                if (cards[i].rank > other.cards[i].rank) return 1;
                if (cards[i].rank < other.cards[i].rank) return -1;
            }
        }

        return 0;
    }
};


std::vector<Card> createDeck() {
    std::vector<Card> deck;
    for (int suit = 0; suit < 4; suit++) {
        for (int rank = 1; rank <= 13; rank++) {
            deck.push_back({static_cast<Rank>(rank), static_cast<Suit>(suit)});
        }
    }
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(deck.begin(), deck.end(), g);
    return deck;
}

// Function to deal hands
std::vector<Hand> dealHands(std::vector<Card>& deck, int numHands) {
    std::vector<Hand> hands(numHands);
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < numHands; j++) {
            hands[j].cards.push_back(deck.back());
            deck.pop_back();
        }
    }
    return hands;
}

// Function to analyze hands
std::vector<Hand> analyzeHands(const std::vector<Hand>& hands) {
    std::vector<Hand> sortedHands = hands;
    std::sort(sortedHands.begin(), sortedHands.end(), [](const Hand& a, const Hand& b) {
        return a.compare(b) > 0;
    });
    return sortedHands;
}

// Function to print results
void printResults(const std::vector<Hand>& hands) {
    static const std::map<std::string, int> handRankings = {
        {"Royal Straight Flush", 10}, {"Straight Flush", 9}, {"Four of a Kind", 8},
        {"Full House", 7}, {"Flush", 6}, {"Straight", 5}, {"Three of a Kind", 4},
        {"Two Pair", 3}, {"Pair", 2}, {"High Card", 1}
    };

    for (int i = 0; i < hands.size(); i++) {
        std::cout << "Hand " << i + 1 << ": " << hands[i] << " - " << hands[i].evaluateRank() << std::endl;
    }
}

// Main function
int main(int argc, char* argv[]) {
    if (argc == 1) {
        std::vector<Card> deck = createDeck();
        std::cout << "*** P O K E R H A N D A N A L Y Z E R ***" << std::endl;
        std::cout << "*** USING RANDOMIZED DECK OF CARDS ***" << std::endl;
        std::cout << "*** Shuffled 52 card deck: ";
        for (const auto& card : deck) {
            std::cout << card << " ";
        }
        std::cout << std::endl;

        std::vector<Hand> hands = dealHands(deck, 6);
        std::cout << "*** Here are the six hands..." << std::endl;
        for (int i = 0; i < hands.size(); i++) {
            std::cout << "Hand " << i + 1 << ": " << hands[i] << std::endl;
        }

        std::vector<Hand> sortedHands = analyzeHands(hands);
        std::cout << "*** --- WINNING HAND ORDER ---" << std::endl;
        printResults(sortedHands);
    } else {
        std::ifstream file(argv[1]);
        if (!file) {
            std::cerr << "Error opening file: " << argv[1] << std::endl;
            return 1;
        }

        std::vector<Hand> hands;
        std::string line;
        while (std::getline(file, line)) {
            std::istringstream iss(line);
            std::string cardStr;
            Hand hand;
            while (iss >> cardStr) {
                char rankChar = cardStr[0];
                char suitChar = cardStr[1];
                Rank rank;
                switch (rankChar) {
                    case 'A': rank = Rank::Ace; break;
                    case 'K': rank = Rank::King; break;
                    case 'Q': rank = Rank::Queen; break;
                    case 'J': rank = Rank::Jack; break;
                    default: rank = static_cast<Rank>(rankChar - '0'); break;
                }
                Suit suit;
                switch (suitChar) {
                    case 'D': suit = Suit::Diamonds; break;
                    case 'C': suit = Suit::Clubs; break;
                    case 'H': suit = Suit::Hearts; break;
                    case 'S': suit = Suit::Spades; break;
                }
                hand.cards.push_back({rank, suit});
            }
            hands.push_back(hand);
        }

        std::cout << "*** P O K E R H A N D A N A L Y Z E R ***" << std::endl;
        std::cout << "*** USING TEST DECK ***" << std::endl;
        std::cout << "*** File: " << argv[1] << std::endl;
        std::cout << "*** Here are the six hands..." << std::endl;
        for (int i = 0; i < hands.size(); i++) {
            std::cout << "Hand " << i + 1 << ": " << hands[i] << std::endl;
        }

        std::vector<Hand> sortedHands = analyzeHands(hands);
        std::cout << "*** --- WINNING HAND ORDER ---" << std::endl;
        printResults(sortedHands);
    }

    return 0;
}