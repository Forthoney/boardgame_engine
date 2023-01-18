# frozen_string_literal: true

require 'boardgame_engine/boardgame'
require 'boardgame_engine/game_modules'
require 'boardgame_engine/board_modules'

# module for playing a game of chess
module Chess
  # Class for a game of chess
  class Game < BoardgameEngine::Game
    include Games::CyclicalTurn
    include Games::MovablePiece

    PLAY_INSTRUCTIONS = 'You can select spots on the board by inputting the ' \
    "row and column with a comma in between. See example below\n1, 1\n"
    GAME_NAME = 'Chess'
    NUM_PLAYERS = 2

    def initialize(names)
      super(Board, names)
    end

    private

    # Check whether a piece can be selected by the player
    #
    # @param [Piece] piece the piece being selected
    #
    # @return [Boolean] whether the piece exists and if so, if it belongs to
    # the player currently going
    def valid_piece?(piece)
      piece && piece.owner == @turn
    end

    def play_turn
      puts "#{@turn}'s turn"
      killed = play_move
      @winner = @turn if killed.is_a?(King)
      change_turn
    end

    def setup_board(board)
      board.new(@players[0], @players[1])
    end
  end

  # Class for a chessboard
  class Board
    include Boards::Grid
    include Boards::MovablePiece

    attr_reader :board

    def initialize(player1, player2)
      @board = generate_board(8, 8)
      setup(player1, player2)
    end

    def display
      super(show_row: true, show_col: true)
    end

    private

    def setup(player1, player2)
      set_pawns(player1, player2)
      set_non_pawns(player1, player2)
    end

    def set_pawns(player1, player2)
      @board[1] = @board[1].map { Pawn.new(player1, 1) }
      @board[-2] = @board[-2].map { Pawn.new(player2, -1) }
    end

    def set_non_pawns(player1, player2)
      pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
      pieces.each_with_index do |piece, idx|
        @board[0][idx] = piece.new(player1)
        @board[7][7 - idx] = piece.new(player2)
      end
    end
  end

  class Pawn < BoardgameEngine::Piece
    def initialize(owner, front)
      super(owner, 'p')
      @first_move = true
      @front = front
    end

    # Check whether the intended destination is a valid destination
    #
    # @param [Array<Integer, Integer>] start_location the start coords
    # @param [Array<Integer, Integer>] end_location the intended destination
    # @param [ChessBoard] board the chess board
    #
    # @return [Boolean] whether the pawn can move to the intended destination
    def valid_move?(start_location, end_location, board)
      row, col = start_location
      end_row, end_col = end_location

      # Checks if moving 1 (or 2 if its the first move) cell forward
      return false unless valid_forward_move?(row, end_row)

      if col == end_col
        valid_line_move?(end_row, end_col, board)
      elsif (col - end_col).abs == 1 && (row + @front == end_row)
        valid_diag_move?(end_row, end_col, board)
      else
        false
      end
    end

    private

    # Check if the pawn can move in a straight line forward to the specified
    # coord
    #
    # @param [Integer] end_row the destination row number
    # @param [Integer] end_col the destination column number
    #
    # @return [Boolean] whether the pawn can move or not
    def valid_line_move?(end_row, end_col, board)
      is_valid_dest = board.get_piece_at([end_row, end_col]).nil?
      @first_move = false if is_valid_dest
      is_valid_dest
    end

    # Check if the pawn can move in a diagonal line to the specified coord
    #
    # @param [Integer] end_row the destination row number
    # @param [Integer] end_col the destination column number
    #
    # @return [Boolean] whether the pawn can move or not
    def valid_diag_move?(end_row, end_col, board)
      other_piece = board.get_piece_at([end_row, end_col])
      @first_move = false if other_piece
      other_piece && (other_piece.owner != @owner)
    end

    # Check if the pawn movement is valid row-wise
    #
    # @param [Integer] row the row the pawn starts from
    # @param [Integer] end_row the destination row
    #
    # @return [Boolean] whether the pawn's row movement is valid numerically
    def valid_forward_move?(row, end_row)
      if @first_move
        (row + @front * 2 == end_row) || (row + @front == end_row)
      else
        row + @front == end_row
      end
    end
  end

  class Queen < BoardgameEngine::Piece
    def initialize(owner)
      super(owner, 'Q')
    end

    def valid_move?(start_location, end_location, board)
      board.clear_diag_path?(start_location, end_location) \
      || board.clear_horz_path?(start_location, end_location) \
      || board.clear_vert_path?(start_location, end_location)
    end
  end

  class Rook < BoardgameEngine::Piece
    def initialize(owner)
      super(owner, 'R')
    end

    def valid_move?(start_location, end_location, board)
      row, col = start_location
      end_row, end_col = end_location

      board.clear_horz_path?(row, col, end_row, end_col, board) \
      || board.clear_vert_path?(row, col, end_row, end_col, board)
    end
  end

  class Bishop < BoardgameEngine::Piece
    def initialize(owner)
      super(owner, 'B')
    end

    def valid_move?(start_location, end_location, board)
      row, col = start_location
      end_row, end_col = end_location

      board.clear_diag_path?(row, col, end_row, end_col, board)
    end
  end

  class King < BoardgameEngine::Piece
    def initialize(owner)
      super(owner, 'K')
    end

    def valid_move?(start_location, end_location, board)
      row, col = start_location
      end_row, end_col = end_location

      return false unless (row - end_row).abs == 1 && (col - end_col).abs == 1

      board.clear_diag_path?(row, col, end_row, end_col, board) \
      || board.clear_horz_path?(row, col, end_row, end_col, board) \
      || board.clear_vert_path?(row, col, end_row, end_col, board)
    end
  end

  class Knight < BoardgameEngine::Piece
    def initialize(owner)
      # K was already taken by king, so I had to choose N
      super(owner, 'N')
    end

    def valid_move?(start_location, end_location, board)
      row, col = start_location
      end_row, end_col = end_location

      within_movement(row, col, end_row, end_col) \
      && not_occupied(end_row, end_col, board)
    end

    private

    def within_movement(row, col, end_row, end_col)
      ((row - end_row).abs == 2 and (col - end_col).abs == 1) \
      || ((row - end_row).abs == 1 and (col - end_col).abs == 2)
    end

    def not_occupied(end_row, end_col, board)
      spot = board.dig(end_row, end_col)
      spot.nil? || spot.owner != @owner
    end
  end
end
