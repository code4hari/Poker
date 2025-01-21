program PokerHandAnalyzer
  implicit none
  integer, parameter :: num_cards = 52, num_hands = 6, cards_per_hand = 5
  integer :: deck(num_cards), rank(num_hands), suit(num_hands)
  character(len=2) :: card_names(num_cards)
  integer :: hand(num_hands, cards_per_hand)
  integer :: i, j

  ! Initialize card names and deck
  call initialize_deck(deck, card_names)

  ! Shuffle the deck
  call shuffle(deck)

  ! Deal the hands
  call deal_hands(deck, hand)

  ! Display shuffled deck
  print *, "*** P O K E R H A N D A N A L Y Z E R ***"
  print *, "*** USING RANDOMIZED DECK OF CARDS ***"
  print *, "*** Shuffled 52 card deck:"
  call display_deck(deck, card_names)

  ! Display the hands
  print *, "*** Here are the six hands...***"
  call display_hands(hand, card_names)

  ! Evaluate and display the hand rankings
  call evaluate_hands(hand, rank, suit)
  call display_rankings(hand, rank, card_names)

contains

!---------------------------------------------------
subroutine initialize_deck(deck, card_names)
  integer, intent(out) :: deck(num_cards)
  character(len=2), intent(out) :: card_names(num_cards)
  integer :: i, j, idx
  character(len=1), dimension(4) :: suits = (/'C', 'D', 'H', 'S'/)
  character(len=1), dimension(13) :: ranks = (/'2', '3', '4', '5', '6', '7', '8', '9', & 
                                              'T', 'J', 'Q', 'K', 'A'/)

  ! Initialize deck and assign card names
  idx = 1
  do i = 1, 4
     do j = 1, 13
        card_names(idx) = ranks(j) // suits(i)
        deck(idx) = idx
        idx = idx + 1
     end do
  end do
end subroutine initialize_deck

!---------------------------------------------------
subroutine shuffle(deck)
  integer, intent(inout) :: deck(num_cards)
  integer :: i, j, temp
  real :: rand_val

  call random_seed()  ! Seed the random number generator

  do i = num_cards, 2, -1
     call random_number(rand_val)
     j = int(rand_val * i) + 1
     ! Swap cards
     temp = deck(i)
     deck(i) = deck(j)
     deck(j) = temp
  end do
end subroutine shuffle

!---------------------------------------------------
subroutine deal_hands(deck, hand)
  integer, intent(in) :: deck(num_cards)
  integer, intent(out) :: hand(:, :)  ! Assumed-shape array
  integer :: i, j, k

  k = 1
  do i = 1, size(hand, 1)  ! Loop over number of hands
     do j = 1, size(hand, 2)  ! Loop over cards per hand
        hand(i, j) = deck(k)
        k = k + 1
     end do
  end do
end subroutine deal_hands

!---------------------------------------------------
subroutine display_deck(deck, card_names)
  integer, intent(in) :: deck(num_cards)
  character(len=2), intent(in) :: card_names(num_cards)
  integer :: i

  do i = 1, num_cards
     write(*, '(A2,1X)', advance='no') card_names(deck(i))
     if (mod(i, 10) == 0) print *
  end do
  print *
end subroutine display_deck

!---------------------------------------------------
subroutine display_hands(hand, card_names)
  integer, intent(in) :: hand(:, :)  ! Assumed-shape array
  character(len=2), intent(in) :: card_names(num_cards)
  integer :: i, j

  do i = 1, size(hand, 1)
     write(*, '(A, I1, A)', advance='no') "Hand ", i, ": "
     do j = 1, size(hand, 2)
        write(*, '(A2,1X)', advance='no') card_names(hand(i, j))
     end do
     print *
  end do
end subroutine display_hands

!---------------------------------------------------
subroutine evaluate_hands(hand, rank, suit)
  integer, intent(in) :: hand(:, :)  ! Assumed-shape array
  integer, intent(out) :: rank(size(hand, 1)), suit(size(hand, 1))
  integer :: i

  ! Placeholder: Assign random ranks for demonstration
  do i = 1, size(hand, 1)
     rank(i) = mod(i, 4) + 1  ! Random rank (1 to 4)
     suit(i) = i
  end do
end subroutine evaluate_hands

!---------------------------------------------------
subroutine display_rankings(hand, rank, card_names)
  integer, intent(in) :: rank(num_hands)
  integer, intent(in) :: hand(:, :)  ! Assumed-shape array
  character(len=2), intent(in) :: card_names(num_cards)
  integer :: i, j
  integer :: sorted_idx(num_hands), temp_rank, temp_idx

  ! Initialize the sorted indices array
  do i = 1, num_hands
     sorted_idx(i) = i
  end do

  ! Sort the hands by rank (descending order)
  do i = 1, num_hands - 1
     do j = i + 1, num_hands
        if (rank(sorted_idx(i)) < rank(sorted_idx(j))) then
           ! Swap the indices
           temp_idx = sorted_idx(i)
           sorted_idx(i) = sorted_idx(j)
           sorted_idx(j) = temp_idx
        end if
     end do
  end do

  ! Print the sorted hands
  print *, "--- WINNING HAND ORDER ---"
  do i = 1, num_hands
     j = sorted_idx(i)  ! Get the index of the sorted hand
     write(*, '(A, I1, A, 5(A2,1X), A)', advance='no') "Hand ", j, ": ", &
          card_names(hand(j, 1)), card_names(hand(j, 2)), &
          card_names(hand(j, 3)), card_names(hand(j, 4)), &
          card_names(hand(j, 5)), " - "

     select case (rank(j))
        case (1)
           print *, "High Card"
        case (2)
           print *, "Pair"
        case (3)
           print *, "Two Pair"
        case (4)
           print *, "Three of a Kind"
     end select
  end do
end subroutine display_rankings

end program PokerHandAnalyzer
