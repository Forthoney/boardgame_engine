# frozen_string_literal: true

# Module for different game rules
module Games
  # Cyclical turn system
  module CyclicalTurn
    def change_turn
      idx = @players.find_index(@turn)
      next_idx = idx < @players.length ? idx + 1 : 0
      @turn = @players[next_idx]
    end
  end

  # Pieces are moved
  module MovablePiece
    def play_move
      puts 'Select your piece'
      piece, row, col = select_piece_from_input
      puts "Select where to move \"#{piece}\" to. Type \"back\" to reselect piece"
      dest = select_destination(piece, row, col)
      return play_move if dest == 'back'

      @board.move_piece([row, col], dest)
    end

    private

    def select_piece_from_input
      input = get_proper_input
      row, col = input.split(',').map(&:to_i)
      piece = @board.get_piece_at([row, col])

      if valid_piece?(piece)
        [piece, row, col]
      else
        puts 'Invalid piece. Try again'
        select_piece_from_input
      end
    end

    def select_destination(piece, row, col)
      input = get_valid_board_input(['back'])
      return 'back' if input == 'back'

      end_row, end_col = input.split(',').map(&:to_i)
      if piece.valid_move?(row, col, end_row, end_col, @board.board)
        [end_row, end_col]
      else
        puts 'Invalid destination. Try again'
        select_destination(piece, row, col)
      end
    end
  end
end
