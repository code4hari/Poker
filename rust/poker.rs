use std::collections::HashMap;

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
enum Suit {
    Diamonds,
    Clubs,
    Hearts,
    Spades,
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
struct Card {
    rank: String,
    suit: Suit,
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
struct Hand {
    cards: Vec<Card>,
    hand_type: HandType,
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
enum HandType {
    RoyalFlush,
    StraightFlush,
    FourOfAKind,
    FullHouse,
    Flush,
    Straight,
    ThreeOfAKind,
    TwoPair,
    OnePair,
    HighCard,
}

impl Card {
    fn new(rank: &str, suit: Suit) -> Self {
        Card {
            rank: rank.to_string(),
            suit,
        }
    }

    fn rank_value(&self) -> usize {
        match self.rank.as_str() {
            "2" => 2,
            "3" => 3,
            "4" => 4,
            "5" => 5,
            "6" => 6,
            "7" => 7,
            "8" => 8,
            "9" => 9,
            "10" => 10,
            "J" => 11,
            "Q" => 12,
            "K" => 13,
            "A" => 14,
            _ => 0,
        }
    }

    fn suit_char(&self) -> char {
        match self.suit {
            Suit::Diamonds => 'D',
            Suit::Clubs => 'C',
            Suit::Hearts => 'H',
            Suit::Spades => 'S',
        }
    }

    fn card_string(&self) -> String {
        format!("{}{}", self.rank, self.suit_char())
    }
}

fn generate_deck() -> Vec<Card> {
    let suits = vec![Suit::Diamonds, Suit::Clubs, Suit::Hearts, Suit::Spades];
    let ranks = vec![
        "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A",
    ];

    let mut deck = Vec::new();
    for suit in &suits {
        for rank in &ranks {
            deck.push(Card::new(rank, suit.clone()));
        }
    }
    deck
}

fn shuffle_deck(mut deck: Vec<Card>) -> Vec<Card> {
    // Deterministic shuffle: reverse first, then interleave in pairs.
    deck.reverse();
    let mut shuffled = Vec::new();
    while deck.len() >= 2 {
        shuffled.push(deck.remove(0));
        shuffled.push(deck.pop().unwrap());
    }
    if !deck.is_empty() {
        shuffled.push(deck.pop().unwrap());
    }
    shuffled
}

fn deal_hands(deck: &[Card]) -> Vec<Hand> {
    let mut hands = Vec::new();
    for i in 0..6 {
        let hand_cards = deck[i * 5..(i + 1) * 5].to_vec();
        let hand_type = analyze_hand(&hand_cards);
        hands.push(Hand {
            cards: hand_cards,
            hand_type,
        });
    }
    hands
}

fn analyze_hand(cards: &[Card]) -> HandType {
    let mut ranks = cards.iter().map(|card| card.rank_value()).collect::<Vec<_>>();
    let suits = cards.iter().map(|card| &card.suit).collect::<Vec<_>>();

    ranks.sort_unstable();
    let rank_counts = ranks.iter().fold(HashMap::new(), |mut acc, &rank| {
        *acc.entry(rank).or_insert(0) += 1;
        acc
    });

    let is_flush = suits.iter().all(|&suit| suit == suits[0]);
    let is_straight = ranks
        .windows(2)
        .all(|pair| pair[1] == pair[0] + 1 || pair == &[14, 2]);

    if is_straight && is_flush && ranks[0] == 10 {
        HandType::RoyalFlush
    } else if is_straight && is_flush {
        HandType::StraightFlush
    } else if rank_counts.values().any(|&count| count == 4) {
        HandType::FourOfAKind
    } else if rank_counts.values().any(|&count| count == 3)
        && rank_counts.values().any(|&count| count == 2)
    {
        HandType::FullHouse
    } else if is_flush {
        HandType::Flush
    } else if is_straight {
        HandType::Straight
    } else if rank_counts.values().any(|&count| count == 3) {
        HandType::ThreeOfAKind
    } else if rank_counts.values().filter(|&&count| count == 2).count() == 2 {
        HandType::TwoPair
    } else if rank_counts.values().any(|&count| count == 2) {
        HandType::OnePair
    } else {
        HandType::HighCard
    }
}

fn display_hand(hand: &Hand) {
    let cards = hand
        .cards
        .iter()
        .map(|card| card.card_string())
        .collect::<Vec<_>>()
        .join(" ");
    println!("{:20} - {:?}", cards, hand.hand_type);
}

fn main() {
    println!("*** P O K E R H A N D A N A L Y Z E R ***");
    let deck = generate_deck();
    let shuffled_deck = shuffle_deck(deck);

    println!("\n*** Dealing Hands ***");
    let hands = deal_hands(&shuffled_deck);
    for hand in &hands {
        display_hand(hand);
    }

    println!("\n--- WINNING HAND ORDER ---");
    let mut sorted_hands = hands.clone();
    sorted_hands.sort_by(|a, b| b.hand_type.cmp(&a.hand_type));
    for hand in &sorted_hands {
        display_hand(hand);
    }
}
