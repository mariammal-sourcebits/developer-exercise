class Card
  attr_accessor :suite, :name, :value

  def initialize(suite, name, value)
    @suite, @name, @value = suite, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITES = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITES.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards, :allow_push

  def initialize(player)
    @allow_push = (player == 'dealer' ? true : false)
    @cards = []
  end

  def points
    # Don't disclose all the cards until stand.
    if @allow_push
      points = (@cards[0].value.class == Array ? @cards[0].value.first : @cards.first.value)
    else
      points = @cards.map{|pts| pts.value.class == Array ? pts.value.first : pts.value}.inject(:+)
    end

    # Determine the ace face value before resulting.
    # Take the next value of ace if needed.
    (points > 21 ? points - (10 * @cards.select {|crd| crd.name == :ace }.size) : points) 
  end

  # Show the cards in the Hand.
  def show_cards
    @allow_push ? "#{@cards.first.value} #{@cards.first.suite}" : @cards.collect {|crd| "#{crd.value} #{crd.suite}"}.join(' | ')
  end
end

class BlackJack
  attr_reader :status                       # Result to the player

  def initialize
    @deck = Deck.new                    # Load the deck for a game.
    @dealer = Hand.new('dealer') # Considered only two players(dealer, player).
    @player = Hand.new('player')
    @status = ''                              # Track the game state for player.
    _assign                                       # Load the initial cards for the players from the deck.
  end

  def player_points
    @player.points 
  end

  def dealer_points
    @dealer.points
  end

  def player_cards 
    @player.show_cards
  end

  def dealer_cards
    @dealer.show_cards 
  end

  def is_bust?(hand)
    hand.points > 21 ? true : false
  end
  
  def hit
    # Get the card from the deck and don't compare with dealer.
    # There are chances for push.
    @player.cards << @deck.deal_card
    @status = (is_bust?(@player) ? "Bust" : @status)
  end
  
  def stand
    # It accepts cards and points will be calculated from the entire hand.
    @dealer.allow_push = false
    
    # Before taking the card,  check if points whether crossed 21.
    # Do not compare with player until loop ends.
    while @dealer.points < 18 && @status == ''
      @dealer.cards << @deck.deal_card
      @status = "Win" if is_bust?(@dealer)
    end

    # Compare with the player and dealer.
    # Game must be concluded.
    if @status == ''
      @status = "Push"
      @status = (@dealer.points > @player.points ? "Bust" : "Win") if @dealer.points < 22
    end
  end

  private
  def _assign
    # Assign cards for players.
    2.times do
     @player.cards << @deck.deal_card
     @dealer.cards << @deck.deal_card
    end
    
    # check player for BJ.
    if @player.points == 21 && @player.cards.size == 2
      @dealer.allow_push = true # Reveal whole cards in the dealer hand.
      # Check there may be chances for push
      @status = (@dealer.points == 21 ? 'Push' : 'Win' )
    end
    @status
  end
end

require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suite_is_correct
    assert_equal @card.suite, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert_equal(false, @deck.playable_cards.include?(card))
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end

class BlackJackTest < Test::Unit::TestCase
  def setup
    @game = BlackJack.new
  end

  def test_check_player_cards_not_empty
    assert_equal false, @game.player_cards.empty?
  end

  def test_check_dealer_cards_not_empty
    assert_equal false, @game.player_cards.empty?
  end

  def test_check_dealer_points_not_nil
    assert_not_nil @game.dealer_points
  end

  def test_check_player_points_not_nil
    assert_not_nil @game.player_points
  end

  def test_check_dealer_points_is_integer
    assert_equal Fixnum, @game.dealer_points.class
  end

  def test_check_hit_not_nil
    assert_not_nil @game.hit
  end

  def test_check_dealer_points_is_integer
    assert_equal Fixnum, @game.dealer_points.class
  end

  def test_check_dealer_points_is_valid
    assert @game.dealer_points > 1 && @game.dealer_points < 22
  end

  def test_check_player_points_is_valid
    assert @game.player_points > 1 && @game.player_points < 22
  end
end