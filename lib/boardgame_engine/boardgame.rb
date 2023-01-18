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

  # Class representing a board game.
  class Boardgame
    PLAY_INSTRUCTIONS = ''
    EXIT_INSTRUCTIONS ||= "Try a sample input or input 'back' to leave the " \
    "tutorial. Type in 'exit' anytime to exit the game fully"
    GAME_NAME = 'Boardgame'

    # Begins a round of the Game
    #
    # @param [Boolean] do_onboarding optional argument on whether to do
    # onboarding
    # @param [Integer] num_players the number of players
    #
    # @return [void]
    def self.play(do_onboarding: true, num_players: 2)
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

    # String representation of the game
    #
    # @return [String] <description>
    def to_s
      "#{self.class::GAME_NAME} between #{@players.join(', ')}"
    end

    protected

    def initialize(board, names)
      @players = names.map { |name| Player.new name }
      @board = setup_board(board)
      @winner = nil
    end

    # Execute onboarding sequence
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

    def tutorial
      puts self.class::PLAY_INSTRUCTIONS + self.class::EXIT_INSTRUCTIONS
      input = gets.chomp
      until input == 'back'
        exit if input == 'exit'
        puts valid_input?(input) ? 'Valid input' : 'Invalid input'
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

    protected

    def clear_diag_path?(row, col, end_row, end_col, board)
      ((end_row - row).abs == (end_col - col).abs) \
      && clear_path?(row, col, end_row, end_col, board)
    end

    def clear_horz_path?(row, col, end_row, end_col, board)
      (end_row == row) && clear_path?(row, col, end_row, end_col, board)
    end

    def clear_vert_path?(row, col, end_row, end_col, board)
      (end_col == col) && clear_path?(row, col, end_row, end_col, board)
    end

    private

    def next_cell(row, col, end_row, end_col)
      row_move = 0
      col_move = 0

      col_move = (end_col - col) / (end_col - col).abs if end_col != col
      row_move = (end_row - row) / (end_row - row).abs if end_row != row

      [row + row_move, col + col_move]
    end

    def clear_path?(row, col, end_row, end_col, board)
      current_tile = board.dig(row, col)
      if (row == end_row) && (col == end_col)
        current_tile.nil? || (current_tile.owner != @owner)
      elsif current_tile.nil? || current_tile.equal?(self)
        next_row, next_col = next_cell(row, col, end_row, end_col)
        clear_path?(next_row, next_col, end_row, end_col, board)
      else
        false
      end
    end
  end
end
