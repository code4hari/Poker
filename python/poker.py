import sys
import random


ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
suits = ['D', 'C', 'H', 'S']


hand_rankings = {
    'Royal Straight Flush': 10,
    'Straight Flush': 9,
    'Four of a Kind': 8,
    'Full House': 7,
    'Flush': 6,
    'Straight': 5,
    'Three of a Kind': 4,
    'Two Pair': 3,
    'Pair': 2,
    'High Card': 1
}


class Card:
    def __init__(self, rank, suit):
        self.rank = rank
        self.suit = suit

    def __repr__(self):
        return f'{self.rank}{self.suit}'


class Hand:
    def __init__(self, cards):
        self.cards = cards

    def __repr__(self):
        return ' '.join([str(card) for card in self.cards])

    def evaluate(self):
        rank = self.evaluate_rank()
        suit = self.evaluate_suit()
        return rank, suit

    def evaluate_rank(self):
        counts = {}
        for card in self.cards:
            if card.rank in counts:
                counts[card.rank] += 1
            else:
                counts[card.rank] = 1

        is_straight = len(counts) == 5 and max(ranks.index(card.rank) for card in self.cards) - min(ranks.index(card.rank) for card in self.cards) == 4

        if is_straight and len(set(card.suit for card in self.cards)) == 1:
            if 'A' in counts and '10' in counts and 'J' in counts and 'Q' in counts and 'K' in counts:
                return 'Royal Straight Flush'
            else:
                return 'Straight Flush'
        elif 4 in counts.values():
            return 'Four of a Kind'
        elif 3 in counts.values() and 2 in counts.values():
            return 'Full House'
        elif len(set(card.suit for card in self.cards)) == 1:
            return 'Flush'
        elif is_straight:
            return 'Straight'
        elif 3 in counts.values():
            return 'Three of a Kind'
        elif list(counts.values()).count(2) == 2:
            return 'Two Pair'
        elif 2 in counts.values():
            return 'Pair'
        else:
            return 'High Card'

    def evaluate_suit(self):
        suit_counts = {}
        for card in self.cards:
            if card.suit in suit_counts:
                suit_counts[card.suit] += 1
            else:
                suit_counts[card.suit] = 1

        if len(suit_counts) == 1:
            return list(suit_counts.keys())[0]
        else:
            highest_suit = max(suit_counts, key=lambda x: 'DCHS'.index(x))
            return highest_suit

    def compare(self, other):
        rank1, suit1 = self.evaluate()
        rank2, suit2 = other.evaluate()

        if hand_rankings[rank1] > hand_rankings[rank2]:
            return 1
        elif hand_rankings[rank1] < hand_rankings[rank2]:
            return -1
        else:
            if rank1 in ['Royal Straight Flush', 'Straight Flush', 'Flush']:
                if 'DCHS'.index(suit1) < 'DCHS'.index(suit2):
                    return 1
                elif 'DCHS'.index(suit1) > 'DCHS'.index(suit2):
                    return -1
                else:
                    return 0
            elif rank1 == 'Straight':
                card_ranks = {'A': 14, 'K': 13, 'Q': 12, 'J': 11, 'T': 10, '9': 9, '8': 8, '7': 7, '6': 6, '5': 5, '4': 4, '3': 3, '2': 2}
                straight_cards1 = sorted([card_ranks[card.rank] for card in self.cards], reverse=True)
                straight_cards2 = sorted([card_ranks[card.rank] for card in other.cards], reverse=True)
                for i in range(len(straight_cards1)):
                    if straight_cards1[i] > straight_cards2[i]:
                        return 1
                    elif straight_cards1[i] < straight_cards2[i]:
                        return -1
                suit1 = 'DCHS'.index(self.cards[-1].suit)
                suit2 = 'DCHS'.index(other.cards[-1].suit)
                if suit1 < suit2:
                    return 1
                elif suit1 > suit2:
                    return -1
                else:
                    return 0
            elif rank1 == 'Two Pair':
                pair_ranks1 = [rank for rank, count in self.evaluate_rank().items() if count == 2]
                pair_ranks2 = [rank for rank, count in other.evaluate_rank().items() if count == 2]
                pair_ranks1.sort(key=lambda x: ranks.index(x), reverse=True)
                pair_ranks2.sort(key=lambda x: ranks.index(x), reverse=True)
                for i in range(len(pair_ranks1)):
                    if ranks.index(pair_ranks1[i]) > ranks.index(pair_ranks2[i]):
                        return 1
                    elif ranks.index(pair_ranks1[i]) < ranks.index(pair_ranks2[i]):
                        return -1
                kicker1 = [card for card in self.cards if card.rank not in pair_ranks1][0]
                kicker2 = [card for card in other.cards if card.rank not in pair_ranks2][0]
                if ranks.index(kicker1.rank) > ranks.index(kicker2.rank):
                    return 1
                elif ranks.index(kicker1.rank) < ranks.index(kicker2.rank):
                    return -1
                else:
                    suit1 = 'DCHS'.index(kicker1.suit)
                    suit2 = 'DCHS'.index(kicker2.suit)
                    if suit1 < suit2:
                        return 1
                    elif suit1 > suit2:
                        return -1
                    else:
                        return 0
            elif rank1 == 'Pair':
                pair_ranks1 = [rank for rank, count in self.evaluate_rank().items() if count == 2]
                pair_ranks2 = [rank for rank, count in other.evaluate_rank().items() if count == 2]
                if ranks.index(pair_ranks1[0]) > ranks.index(pair_ranks2[0]):
                    return 1
                elif ranks.index(pair_ranks1[0]) < ranks.index(pair_ranks2[0]):
                    return -1
                kicker1 = [card for card in self.cards if card.rank not in pair_ranks1]
                kicker2 = [card for card in other.cards if card.rank not in pair_ranks2]
                kickers1 = sorted(kicker1, key=lambda x: ranks.index(x.rank), reverse=True)
                kickers2 = sorted(kicker2, key=lambda x: ranks.index(x.rank), reverse=True)
                for i in range(len(kickers1)):
                    if ranks.index(kickers1[i].rank) > ranks.index(kickers2[i].rank):
                        return 1
                    elif ranks.index(kickers1[i].rank) < ranks.index(kickers2[i].rank):
                        return -1
                suit1 = 'DCHS'.index(kickers1[0].suit)
                suit2 = 'DCHS'.index(kickers2[0].suit)
                if suit1 < suit2:
                    return 1
                elif suit1 > suit2:
                    return -1
                else:
                    return 0
            elif rank1 == 'High Card':
                cards1 = sorted(self.cards, key=lambda x: ranks.index(x.rank), reverse=True)
                cards2 = sorted(other.cards, key=lambda x: ranks.index(x.rank), reverse=True)
                for i in range(len(cards1)):
                    if ranks.index(cards1[i].rank) > ranks.index(cards2[i].rank):
                        return 1
                    elif ranks.index(cards1[i].rank) < ranks.index(cards2[i].rank):
                        return -1
                suit1 = 'DCHS'.index(cards1[0].suit)
                suit2 = 'DCHS'.index(cards2[0].suit)
                if suit1 < suit2:
                    return 1
                elif suit1 > suit2:
                    return -1
                else:
                    return 0
            else:
                return 0


def create_deck():
    deck = [Card(rank, suit) for rank in ranks for suit in suits]
    random.shuffle(deck)
    return deck


def deal_hands(deck, num_hands):
    hands = [[] for _ in range(num_hands)]
    for _ in range(5):
        for hand in hands:
            hand.append(deck.pop(0))  
    return [Hand(hand) for hand in hands]


def analyze_hands(hands):
    sorted_hands = sorted(hands, key=lambda x: x.evaluate(), reverse=True)
    return sorted_hands


def print_results(hands):
    for i, hand in enumerate(hands):
        rank, suit = hand.evaluate()
        print(f'Hand {i+1}: {hand} - {rank}')


def main():
    if len(sys.argv) == 1:
        deck = create_deck()
        print('*** P O K E R H A N D A N A L Y Z E R ***')
        print('*** USING RANDOMIZED DECK OF CARDS ***')
        print('*** Shuffled 52 card deck:')
        print(' '.join([str(card) for card in deck]))  
        hands = deal_hands(deck[:], 6)  
        print('*** Here are the six hands...')
        for i, hand in enumerate(hands):
            print(f'Hand {i+1}: {hand}')
        sorted_hands = analyze_hands(hands)
        print('--- WINNING HAND ORDER ---')
        print_results(sorted_hands)
    else:
        filename = sys.argv[1]
        print('*** P O K E R H A N D A N A L Y Z E R ***')
        print('*** USING TEST DECK ***')
        print(f'*** File: {filename}')
        with open(filename, 'r') as f:
            hands = [Hand([Card(card[0], card[1]) for card in line.strip().split(', ')]) for line in f.readlines()]
        print('*** Here are the six hands...')
        for i, hand in enumerate(hands):
            print(f'Hand {i+1}: {hand}')
        sorted_hands = analyze_hands(hands)
        print('--- WINNING HAND ORDER ---')
        print_results(sorted_hands)

if __name__ == '__main__':
    main()