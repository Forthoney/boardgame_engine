# frozen_string_literal: true

# All classes in this script are intended to be abstract, meaning they should
# not be called on their own.

module BoardgameEngine
  # Class representing a physical board comprised of a grid in a board game. It
  # acts as both the View and Model if the project were to be compared to a MVC
  # model. It plays both roles as the board in a board game not only stores data,
  # but also IS the data that must be shown to the players.
  class Board
    attr_reader :board

    private

    def spot_playable?(piece, row, col)
      piece.possible_moves.include? [row, col]
    end
  end

  # Class representing a player in a game
  class Player
    attr_reader :name

    # Creates a player object with the given name
    # @param [String] name
    def initialize(name)
      @name = name
    end

    def to_s
      @name.to_s
    end
  end

  # Class representing a board game.
  class Boardgame
    EXIT_INSTRUCTIONS ||= "Try a sample input or input 'back' to leave the " \
    "tutorial. Type in 'exit' anytime to exit the game fully"

    def initialize(board, instructions, names)
      @players = names.map { |name| Player.new name }
      @board = setup_board(board)
      @instructions = instructions
      @winner = nil
    end

    def self.play(do_onboarding, num_players = 2)
      names = []
      num_players.times do |i|
        puts "What is Player #{i}'s name?"
        names.push(gets.chomp)
      end

      @game = new(names)

      puts "Welcome to #{@game}!"
      @game.onboarding if do_onboarding
      puts "Starting #{@game}..."
      @game.start
    end

    def to_s(game_name = 'boardgame')
      "#{game_name} between #{@players.join(', ')}"
    end

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

    def tutorial
      puts @instructions + Boardgame::EXIT_INSTRUCTIONS
      input = gets.chomp
      until input == 'back'
        exit if input == 'exit'
        puts valid_input?(input) ? 'Valid input!' : 'Invalid input'
        input = gets.chomp
      end
    end

    def start(turn = @players[0])
      @turn = turn
      @board.display
      until @winner
        play_turn
        @board.display
      end
      puts "#{@winner} wins!"
    end

    protected

    def get_valid_board_input(special_commands = [])
      input = gets.chomp

      until @board.valid_board_input?(input) || special_commands.include?(input)
        exit if input == 'exit'

        puts 'Invalid input. Try again'
        input = gets.chomp
      end

      input
    end

    def setup_board(board)
      board.new
    end
  end
end
