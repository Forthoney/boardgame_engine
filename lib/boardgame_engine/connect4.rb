# frozen_string_literal: true

require 'boardgame_engine/boardgame'
require 'boardgame_engine/game_modules'
require 'boardgame_engine/board_modules'

module SampleConnect4
  class Connect4Board < BoardgameEngine::Board
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

  class Connect4 < BoardgameEngine::Boardgame
    include Games::CyclicalTurn

    @instructions = 'You can select which column to drop you chip into by' \
    ' typing in the row number.'

    def initialize(names)
      super(Connect4Board, @instructions, names)
    end

    def to_s
      super('connect-four')
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
end
