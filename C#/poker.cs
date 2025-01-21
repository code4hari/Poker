using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class Card
{
    public string Rank { get; }
    public char Suit { get; }

    public Card(string rank, char suit)
    {
        Rank = rank;
        Suit = suit;
    }

    public override string ToString()
    {
        return $"{Rank}{Suit}";
    }
}

class Hand
{
    public List<Card> Cards { get; }

    public Hand(List<Card> cards)
    {
        Cards = cards;
    }

    public override string ToString()
    {
        return string.Join(" ", Cards);
    }

    public (string, char) Evaluate()
    {
        string rank = EvaluateRank();
        char suit = EvaluateSuit();
        return (rank, suit);
    }

    private string EvaluateRank()
    {
        var counts = Cards.GroupBy(c => c.Rank)
                          .ToDictionary(g => g.Key, g => g.Count());

        bool isStraight = counts.Count == 5 &&
                          Program.Ranks.IndexOf(Cards.Max(c => c.Rank)) - Program.Ranks.IndexOf(Cards.Min(c => c.Rank)) == 4;

        bool isFlush = Cards.Select(c => c.Suit).Distinct().Count() == 1;

        if (isStraight && isFlush)
        {
            if (counts.ContainsKey("A") && counts.ContainsKey("10") &&
                counts.ContainsKey("J") && counts.ContainsKey("Q") && counts.ContainsKey("K"))
            {
                return "Royal Straight Flush";
            }
            return "Straight Flush";
        }
        if (counts.Values.Contains(4)) return "Four of a Kind";
        if (counts.Values.Contains(3) && counts.Values.Contains(2)) return "Full House";
        if (isFlush) return "Flush";
        if (isStraight) return "Straight";
        if (counts.Values.Contains(3)) return "Three of a Kind";
        if (counts.Values.Count(v => v == 2) == 2) return "Two Pair";
        if (counts.Values.Contains(2)) return "Pair";
        return "High Card";
    }

    private char EvaluateSuit()
    {
        var suitCounts = Cards.GroupBy(c => c.Suit)
                              .ToDictionary(g => g.Key, g => g.Count());

        if (suitCounts.Count == 1) return suitCounts.Keys.First();
        return suitCounts.OrderByDescending(kv => "DCHS".IndexOf(kv.Key)).First().Key;
    }

    public int CompareTo(Hand other)
    {
        var (rank1, suit1) = Evaluate();
        var (rank2, suit2) = other.Evaluate();

        if (Program.HandRankings[rank1] > Program.HandRankings[rank2]) return 1;
        if (Program.HandRankings[rank1] < Program.HandRankings[rank2]) return -1;

        if (rank1 == "Straight Flush" || rank1 == "Flush")
        {
            return "DCHS".IndexOf(suit1).CompareTo("DCHS".IndexOf(suit2));
        }

        return CompareHighCard(other);
    }

    private int CompareHighCard(Hand other)
    {
        var sortedCards1 = Cards.OrderByDescending(c => Program.Ranks.IndexOf(c.Rank)).ToList();
        var sortedCards2 = other.Cards.OrderByDescending(c => Program.Ranks.IndexOf(c.Rank)).ToList();

        for (int i = 0; i < sortedCards1.Count; i++)
        {
            int comparison = Program.Ranks.IndexOf(sortedCards1[i].Rank).CompareTo(Program.Ranks.IndexOf(sortedCards2[i].Rank));
            if (comparison != 0) return comparison;
        }

        return "DCHS".IndexOf(sortedCards1[0].Suit).CompareTo("DCHS".IndexOf(sortedCards2[0].Suit));
    }
}

class Program
{
    public static readonly List<string> Ranks = new List<string> { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };
    public static readonly List<char> Suits = new List<char> { 'D', 'C', 'H', 'S' };

    public static readonly Dictionary<string, int> HandRankings = new Dictionary<string, int>
    {
        { "Royal Straight Flush", 10 },
        { "Straight Flush", 9 },
        { "Four of a Kind", 8 },
        { "Full House", 7 },
        { "Flush", 6 },
        { "Straight", 5 },
        { "Three of a Kind", 4 },
        { "Two Pair", 3 },
        { "Pair", 2 },
        { "High Card", 1 }
    };

    static void Main(string[] args)
    {
        if (args.Length == 0)
        {
            var deck = CreateDeck();
            Console.WriteLine("*** P O K E R H A N D A N A L Y Z E R ***");
            Console.WriteLine("*** USING RANDOMIZED DECK OF CARDS ***");
            Console.WriteLine("*** Shuffled 52 card deck:");
            Console.WriteLine(string.Join(" ", deck));

            var hands = DealHands(deck, 6);
            Console.WriteLine("*** Here are the six hands...");
            PrintHands(hands);

            var sortedHands = AnalyzeHands(hands);
            Console.WriteLine("--- WINNING HAND ORDER ---");
            PrintResults(sortedHands);
        }
        else
        {
            string filename = args[0];
            Console.WriteLine("*** P O K E R H A N D A N A L Y Z E R ***");
            Console.WriteLine($"*** File: {filename}");

            var hands = ReadHandsFromFile(filename);
            Console.WriteLine("*** Here are the six hands...");
            PrintHands(hands);

            var sortedHands = AnalyzeHands(hands);
            Console.WriteLine("--- WINNING HAND ORDER ---");
            PrintResults(sortedHands);
        }
    }

    static List<Card> CreateDeck()
    {
        var deck = new List<Card>();
        foreach (var rank in Ranks)
        {
            foreach (var suit in Suits)
            {
                deck.Add(new Card(rank, suit));
            }
        }
        var rand = new Random();
        return deck.OrderBy(_ => rand.Next()).ToList();
    }

    static List<Hand> DealHands(List<Card> deck, int numHands)
    {
        var hands = new List<Hand>();
        for (int i = 0; i < numHands; i++)
        {
            hands.Add(new Hand(deck.Skip(i * 5).Take(5).ToList()));
        }
        return hands;
    }

    static List<Hand> ReadHandsFromFile(string filename)
    {
        var hands = new List<Hand>();
        foreach (var line in File.ReadLines(filename))
        {
            var cards = line.Split(", ").Select(s => new Card(s.Substring(0, s.Length - 1), s.Last())).ToList();
            hands.Add(new Hand(cards));
        }
        return hands;
    }

    static List<Hand> AnalyzeHands(List<Hand> hands)
    {
        return hands.OrderByDescending(h => h.Evaluate()).ToList();
    }

    static void PrintHands(List<Hand> hands)
    {
        for (int i = 0; i < hands.Count; i++)
        {
            Console.WriteLine($"Hand {i + 1}: {hands[i]}");
        }
    }

    static void PrintResults(List<Hand> hands)
    {
        for (int i = 0; i < hands.Count; i++)
        {
            var (rank, suit) = hands[i].Evaluate();
            Console.WriteLine($"Hand {i + 1}: {hands[i]} - {rank}");
        }
    }
}
