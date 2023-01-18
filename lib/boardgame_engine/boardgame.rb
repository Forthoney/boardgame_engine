# frozen_string_literal: true

# All classes in this script are intended to be abstract, meaning they should
# not be called on their own.
module BoardgameEngine
  # Class representing a player in a game
  class Player
    attr_reader :name

    # Creates a player object with the given name
    #
    # @param [String] name the name of the player
    def initialize(name)
      @name = name
    end

    # String representation of player
    #
    # @return [String] the name of the player
    def to_s
      @name.to_s
    end
  end

  # Class representing the game loop. It contains the tutorial sequence and
  # information about the core gameplay loop
  class Game
    PLAY_INSTRUCTIONS = ''
    EXIT_INSTRUCTIONS ||= "Try a sample input or input 'back' to leave the " \
    "tutorial. Type in 'exit' anytime to exit the game fully"
    GAME_NAME = 'Boardgame'
    NUM_PLAYERS = 2

    # Begins a round of the Game
    #
    # @param [Boolean] do_onboarding optional argument on whether to do
    # onboarding
    #
    # @return [void]
    def self.start(do_onboarding: true)
      names = []
      self::NUM_PLAYERS.times do |i|
        puts "What is Player #{i}'s name?"
        names.push(gets.chomp)
      end

      @game = new(names)

      puts "Welcome to #{@game}!"
      @game.onboarding if do_onboarding
      puts "Starting #{@game}..."
      @game.play
    end

    # Execute onboarding sequence where the player is asked if they want a
    # tutorial
    #
    # @return [void]
    def onboarding
      puts "Would you like a tutorial on how to play on this program? \n(y, n)"

      case gets.chomp
      when 'y'
        tutorial
      when 'n'
        puts 'Skipping Tutorial'
      else
        puts 'Please answer either "y" or "n"'
        onboarding
      end
    end

    # Play the game
    #
    # @param [Player] turn the player who is going first
    #
    # @return [void]
    def play(turn = @players[0])
      @turn = turn
      @board.display
      until @winner
        play_turn
        @board.display
        change_turn
      end
      puts "#{@winner} wins!"
    end

    # String representation of the game
    #
    # @return [String] <description>
    def to_s
      "#{self.class::GAME_NAME} between #{@players.join(', ')}"
    end

    protected

    # Constructor for a board game. Kept private so that an object of just class
    # BoardGame cannot be instantiated without being inherited. It essentially
    # keeps it as an abstract class
    #
    # @param [Board] board the board to play on
    # @param [Array<String>] names the names of the players
    def initialize(board, names)
      @players = names.map { |name| Player.new name }
      @board = setup_board(board)
      @winner = nil
    end

    # Run tutorial for the game
    def tutorial
      puts self.class::PLAY_INSTRUCTIONS + self.class::EXIT_INSTRUCTIONS
      input = gets.chomp
      until input == 'back'
        exit if input == 'exit'
        puts @board.valid_board_input?(input) ? 'Valid input' : 'Invalid input'
        input = gets.chomp
      end
    end

    # Prompts a user for a board input until a proper input is received
    #
    # @param [Array<String>] special_commands a list of commands that are not
    # valid board input but are valid commands like "back"
    #
    # @return [String] a valid input
    def get_valid_board_input(special_commands = [])
      input = gets.chomp

      until @board.valid_board_input?(input) || special_commands.include?(input)
        exit if input == 'exit'

        puts 'Invalid input. Try again'
        input = gets.chomp
      end

      input
    end

    # Setup the board
    #
    # @param [Class] board the class of the board to be used in the game
    #
    # @return [Board] a new board
    def setup_board(board)
      board.new
    end
  end

  class Piece
    attr_accessor :status
    attr_reader :owner

    def initialize(owner, name)
      @status = 'alive'
      @owner = owner
      @name = name
    end

    def kill(other)
      other.status = 'dead'
    end

    def to_s
      @name.to_s
    end
  end
end
