using Random

struct Card
    face::String
    suit::String
end

function Base.show(io::IO, card::Card)
    print(io, card.face * card.suit)
end

function Base.isless(a::Card, b::Card)
    face_order = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    suit_order = ["D", "C", "H", "S"]
    
    face_a = findfirst(isequal(a.face), face_order)
    face_b = findfirst(isequal(b.face), face_order)
    suit_a = findfirst(isequal(a.suit), suit_order)
    suit_b = findfirst(isequal(b.suit), suit_order)
    
    if face_a != face_b
        return face_a < face_b
    else
        return suit_a < suit_b
    end
end

function main()
    faces = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    suits = ["D", "C", "H", "S"]

    deck = [Card(face, suit) for face in faces for suit in suits]

    if length(ARGS) == 0
        println("*** P O K E R H A N D A N A L Y Z E R ***")
        println("*** USING RANDOMIZED DECK OF CARDS ***")

        # Shuffle the deck
        shuffle!(deck)

        println("*** Shuffled 52 card deck:")
        print_deck(deck)

        println("*** Here are the six hands...")
        hands = deal_hands(deck, 6, 5)
        for hand in hands
            print_hand(hand)
        end

        println("*** Here is what remains in the deck...")
        print_deck(deck)

        println("--- WINNING HAND ORDER ---")
        sorted_hands = sort_hands(hands)
        for hand in sorted_hands
            print_hand(hand)
            println(" - $(evaluate_hand(hand))")
        end
    else
        filename = ARGS[1]
        println("*** P O K E R H A N D A N A L Y Z E R ***")
        println("*** USING TEST DECK ***")
        println("*** File: $filename")

        hands = []
        open(filename) do file
            for line in eachline(file)
                println(line)
                cards = split(line, ", ")
                hand = [Card(strip(card[1:end-1]), card[end]) for card in cards]
                push!(hands, hand)
            end
        end

        println("*** Here are the six hands...")
        for hand in hands
            print_hand(hand)
        end

        println("--- WINNING HAND ORDER ---")
        sorted_hands = sort_hands(hands)
        for hand in sorted_hands
            print_hand(hand)
            println(" - $(evaluate_hand(hand))")
        end
    end
end

function print_deck(deck)
    for (i, card) in enumerate(deck)
        print(card, " ")
        if i % 13 == 0
            println()
        end
    end
    println()
end

function print_hand(hand)
    for card in hand
        print(card, " ")
    end
    println()
end

function deal_hands(deck, num_hands, cards_per_hand)
    hands = []
    for i in 1:num_hands
        hand = deck[1:cards_per_hand]
        deck = deck[cards_per_hand+1:end]
        push!(hands, hand)
    end
    return hands
end

function evaluate_hand(hand)
    faces = Dict{String,Int}()
    suits = Dict{String,Int}()
    for card in hand
        faces[card.face] = get(faces, card.face, 0) + 1
        suits[card.suit] = get(suits, card.suit, 0) + 1
    end

    unique_faces = collect(keys(faces))
    unique_suits = collect(keys(suits))

    is_flush = length(unique_suits) == 1
    is_straight = false
    if length(unique_faces) == 5
        sorted_faces = sort(unique_faces, by=face -> faces[face])
        is_straight = true
        for i in 2:5
            if faces[sorted_faces[i]] != faces[sorted_faces[i-1]] + 1
                is_straight = false
                break
            end
        end
        if !is_straight && sorted_faces[1] == "A" && sorted_faces[2] == "2" && sorted_faces[3] == "3" && sorted_faces[4] == "4" && sorted_faces[5] == "5"
            is_straight = true
        end
    end

    if is_flush && is_straight
        sorted_faces = sort(unique_faces, by=face -> faces[face])
        if sorted_faces[1] == "10" && sorted_faces[5] == "A"
            return "Royal Straight Flush"
        else
            return "Straight Flush"
        end
    elseif length(unique_faces) == 2
        sorted_faces = sort(unique_faces, by=face -> faces[face], rev=true)
        if faces[sorted_faces[1]] == 4
            return "Four of a Kind"
        else
            return "Full House"
        end
    elseif is_flush
        return "Flush"
    elseif is_straight
        return "Straight"
    elseif length(unique_faces) == 3
        sorted_faces = sort(unique_faces, by=face -> faces[face], rev=true)
        if faces[sorted_faces[1]] == 3
            return "Three of a Kind"
        else
            return "Two Pair"
        end
    elseif length(unique_faces) == 4
        return "Pair"
    else
        return "High Card"
    end
end

function sort_hands(hands)
    sort(hands, by=hand -> begin
        rank = get_rank(evaluate_hand(hand))
        sorted_hand = sort(hand, by=card -> (card.face, card.suit), rev=true)
        (rank, sorted_hand)
    end, rev=true)
end

function get_rank(hand_type)
    ranks = Dict(
        "Royal Straight Flush" => 10,
        "Straight Flush" => 9,
        "Four of a Kind" => 8,
        "Full House" => 7,
        "Flush" => 6,
        "Straight" => 5,
        "Three of a Kind" => 4,
        "Two Pair" => 3,
        "Pair" => 2,
        "High Card" => 1
    )
    return ranks[hand_type]
end

main()