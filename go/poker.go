package main

import (
    "bufio"
    "fmt"
    "math/rand"
    "os"
    "sort"
    "strings"
    "time"
)

type Card struct {
    face string
    suit string
}

func (c Card) toString() string {
    return c.face + c.suit
}

func main() {
    rand.Seed(time.Now().UnixNano())

    faces := []string{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    suits := []string{"D", "C", "H", "S"}

    var deck []Card
    for _, face := range faces {
        for _, suit := range suits {
            deck = append(deck, Card{face, suit})
        }
    }

    if len(os.Args) == 1 {
        fmt.Println("*** P O K E R H A N D A N A L Y Z E R ***")
        fmt.Println("*** USING RANDOMIZED DECK OF CARDS ***")

        // Shuffle the deck
        fisherYatesShuffle(deck)

        fmt.Println("*** Shuffled 52 card deck:")
        printDeck(deck)

        fmt.Println("*** Here are the six hands...")
        hands := dealHands(deck, 6, 5)
        for _, hand := range hands {
            printHand(hand)
        }

        fmt.Println("*** Here is what remains in the deck...")
        printDeck(deck)

        fmt.Println("--- WINNING HAND ORDER ---")
        sortedHands := sortHands(hands)
        for _, hand := range sortedHands {
            printHand(hand)
            fmt.Printf(" - %s\n", evaluateHand(hand))
        }
    } else {
        filename := os.Args[1]
        fmt.Println("*** P O K E R H A N D A N A L Y Z E R ***")
        fmt.Println("*** USING TEST DECK ***")
        fmt.Printf("*** File: %s\n", filename)

        file, err := os.Open(filename)
        if err != nil {
            fmt.Printf("Could not open file '%s' %v", filename, err)
            return
        }
        defer file.Close()

        var hands [][]Card
        scanner := bufio.NewScanner(file)
        for scanner.Scan() {
            line := scanner.Text()
            fmt.Println(line)
            cards := strings.Split(line, ", ")
            var hand []Card
            for _, card := range cards {
                card = strings.TrimSpace(card)
                face := card[:len(card)-1]
                suit := card[len(card)-1:]
                hand = append(hand, Card{face, suit})
            }
            hands = append(hands, hand)
        }

        fmt.Println("*** Here are the six hands...")
        for _, hand := range hands {
            printHand(hand)
        }

        fmt.Println("--- WINNING HAND ORDER ---")
        sortedHands := sortHands(hands)
        for _, hand := range sortedHands {
            printHand(hand)
            fmt.Printf(" - %s\n", evaluateHand(hand))
        }
    }
}

func fisherYatesShuffle(deck []Card) {
    for i := len(deck) - 1; i > 0; i-- {
        j := rand.Intn(i + 1)
        deck[i], deck[j] = deck[j], deck[i]
    }
}

func dealHands(deck []Card, numHands, cardsPerHand int) [][]Card {
    var hands [][]Card
    for i := 0; i < numHands; i++ {
        hand := deck[:cardsPerHand]
        deck = deck[cardsPerHand:]
        hands = append(hands, hand)
    }
    return hands
}

func printDeck(deck []Card) {
    for i, card := range deck {
        fmt.Print(card.toString() + " ")
        if (i+1)%13 == 0 {
            fmt.Println()
        }
    }
    fmt.Println()
}

func printHand(hand []Card) {
    for _, card := range hand {
        fmt.Print(card.toString() + " ")
    }
    fmt.Println()
}

func evaluateHand(hand []Card) string {
    faces := make(map[string]int)
    suits := make(map[string]int)
    for _, card := range hand {
        faces[card.face]++
        suits[card.suit]++
    }

    uniqueFaces := make([]string, 0, len(faces))
    for face := range faces {
        uniqueFaces = append(uniqueFaces, face)
    }
    uniqueSuits := make([]string, 0, len(suits))
    for suit := range suits {
        uniqueSuits = append(uniqueSuits, suit)
    }

    isFlush := len(uniqueSuits) == 1
    isStraight := false
    if len(uniqueFaces) == 5 {
        sort.Slice(uniqueFaces, func(i, j int) bool {
            return faces[uniqueFaces[i]] < faces[uniqueFaces[j]]
        })
        isStraight = true
        for i := 1; i < 5; i++ {
            if faces[uniqueFaces[i]] != faces[uniqueFaces[i-1]]+1 {
                isStraight = false
                break
            }
        }
        if !isStraight && uniqueFaces[0] == "A" && uniqueFaces[1] == "2" && uniqueFaces[2] == "3" && uniqueFaces[3] == "4" && uniqueFaces[4] == "5" {
            isStraight = true
        }
    }

    if isFlush && isStraight {
        sort.Slice(uniqueFaces, func(i, j int) bool {
            return faces[uniqueFaces[i]] < faces[uniqueFaces[j]]
        })
        if uniqueFaces[0] == "10" && uniqueFaces[4] == "A" {
            return "Royal Straight Flush"
        } else {
            return "Straight Flush"
        }
    } else if len(uniqueFaces) == 2 {
        sort.Slice(uniqueFaces, func(i, j int) bool {
            return faces[uniqueFaces[i]] > faces[uniqueFaces[j]]
        })
        if faces[uniqueFaces[0]] == 4 {
            return "Four of a Kind"
        } else {
            return "Full House"
        }
    } else if isFlush {
        return "Flush"
    } else if isStraight {
        return "Straight"
    } else if len(uniqueFaces) == 3 {
        sort.Slice(uniqueFaces, func(i, j int) bool {
            return faces[uniqueFaces[i]] > faces[uniqueFaces[j]]
        })
        if faces[uniqueFaces[0]] == 3 {
            return "Three of a Kind"
        } else {
            return "Two Pair"
        }
    } else if len(uniqueFaces) == 4 {
        return "Pair"
    } else {
        return "High Card"
    }
}

func sortHands(hands [][]Card) [][]Card {
    sort.Slice(hands, func(i, j int) bool {
        rankA := getRank(evaluateHand(hands[i]))
        rankB := getRank(evaluateHand(hands[j]))

        if rankA == rankB {
            sortedA := make([]Card, len(hands[i]))
            copy(sortedA, hands[i])
            sortedB := make([]Card, len(hands[j]))
            copy(sortedB, hands[j])

            sort.Slice(sortedA, func(i, j int) bool {
                return sortedA[i].face > sortedA[j].face
            })
            sort.Slice(sortedB, func(i, j int) bool {
                return sortedB[i].face > sortedB[j].face
            })

            for k := 0; k < 5; k++ {
                if sortedA[k].face != sortedB[k].face {
                    return sortedB[k].face > sortedA[k].face
                } else if sortedA[k].suit != sortedB[k].suit {
                    return sortedB[k].suit > sortedA[k].suit
                }
            }

            return false
        } else {
            return rankB > rankA
        }
    })

    return hands
}

func getRank(handType string) int {
    ranks := map[string]int{
        "Royal Straight Flush": 10,
        "Straight Flush":       9,
        "Four of a Kind":       8,
        "Full House":           7,
        "Flush":                6,
        "Straight":             5,
        "Three of a Kind":      4,
        "Two Pair":             3,
        "Pair":                 2,
        "High Card":            1,
    }

    return ranks[handType]
}