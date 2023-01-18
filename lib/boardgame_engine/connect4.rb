# frozen_string_literal: true

require 'boardgame_engine/boardgame'
require 'boardgame_engine/game_modules'
require 'boardgame_engine/board_modules'

# module for playing a game of Connect-4
module Connect4
  # A game of Connect-4
  class Connect4Game < BoardgameEngine::Boardgame
    include Games::CyclicalTurn

    PLAY_INSTRUCTIONS = 'You can select which column to drop you chip into by' \
    ' typing in the row number.'
    GAME_NAME = 'Connect-4'

    def initialize(names)
      super(Connect4Board, names)
    end

    private

    def play_turn
      puts "#{@turn}'s turn\nChoose a column to drop your chip in"
      col = get_valid_board_input.to_i
      @board.drop_chip(col, @turn)
      @winner = @turn if @board.consecutive?
      change_turn
    end
  end

  # The Connect-4 board
  class Connect4Board
    include Boards::Grid

    def initialize
      @board = generate_board(6, 7)
    end

    def display
      super(show_col: true)
    end

    def drop_chip(col, owner)
      @board.reverse_each do |row|
        if row[col].nil?
          row[col] = owner
          break
        end
      end
    end

    def valid_board_input?(input)
      super(input, only_col: true)
    end
  end
end
