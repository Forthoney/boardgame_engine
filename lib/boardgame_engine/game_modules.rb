# frozen_string_literal: true

# Module for different game rules
module Games
  # Module for games with a cyclical turn system
  # @
  module CyclicalTurn
    # Changes the turn to the next player
    def change_turn
      idx = @players.find_index(@turn)
      next_idx = idx < @players.length ? idx + 1 : 0
      @turn = @players[next_idx]
    end
  end

  # Module for games where game pieces are moved
  module MovablePiece
    # Execute a single move according to player input
    #
    # @return [void]
    def play_move
      puts 'Select your piece'
      piece, row, col = select_piece_from_input
      puts "Select where to move \"#{piece}\" to. Type \"back\" to reselect piece"
      dest = select_destination(piece, row, col)
      return play_move if dest == 'back'

      @board.move_piece([row, col], dest)
    end

    private

    # Select a piece on the board from user input
    #
    # @return [Array] the piece, and the piece's location
    def select_piece_from_input
      location = @board.parse_input(get_valid_board_input)
      piece = @board.get_piece_at(location)

      if valid_piece?(piece)
        [piece, location]
      else
        puts 'Invalid piece. Try again'
        select_piece_from_input
      end
    end

    # Select a location on the board to move to from user input
    #
    # @param [<Type>] piece The piece to move
    # @param [<Type>] start_location the starting location of the piece
    #
    # @return [<Type>] the location of the piece or the string literal 'back'
    def select_destination(piece, start_location)
      input = get_valid_board_input(['back'])
      return 'back' if input == 'back'

      end_location = @board.parse_input(input)
      if piece.valid_move?(start_location, end_location, @board)
        end_location
      else
        puts 'Invalid destination. Try again'
        select_destination(piece, start_location)
      end
    end
  end
end
