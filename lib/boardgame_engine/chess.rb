# frozen_string_literal: true

require_relative "boardgame"
require_relative "multiplayergame"

module SampleChess
  class ChessBoard < BoardgameEngine::Board
    attr_reader :board

    def initialize(player1, player2)
      super(8, 8)
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

  class Chess < BoardgameEngine::Boardgame
    include TwoPlayers

    def initialize(name1 = "Player 1", name2 = "Player 2")
      @instructions = "You can select spots on the board by inputting the row " \
      "and column with a comma in between. See example below\n1, 1\n"
      super(ChessBoard, @instructions, name1, name2)
    end

    def to_s
      super("chess")
    end

    private

    def valid_input?(input)
      coords = input.split(",")
      coords.all? { |c| c.match?(/[[:digit:]]/) && c.to_i.between?(0, 7) }
    end

    def valid_piece?(piece)
      !piece.nil? && piece.owner == @turn
    end

    def select_piece
      input = proper_format_input
      input.split(",").map(&:to_i) => [row, col]
      if valid_piece? @board.board.dig(row, col)
        [row, col]
      else
        puts "Invalid piece. Try again"
        select_piece
      end
    end

    def select_destination(piece, row, col)
      input = proper_format_input(["back"])
      return "back" if input == "back"

      input.split(",").map(&:to_i) => [end_row, end_col]
      if piece.valid_move?(row, col, end_row, end_col, @board.board)
        [end_row, end_col]
      else
        puts "Invalid destination. Try again"
        select_destination(piece, row, col)
      end
    end

    def play_turn
      puts "#{@turn}'s turn\nSelect your piece"
      select_piece => [row, col]
      piece = @board.board[row][col]
      puts "Select where to move #{piece} to. Type back to reselect piece"
      dest = select_destination(piece, row, col)
      return if dest == "back"

      killed = @board.move_piece(row, col, dest[0], dest[1])
      @winner = piece.owner if killed.is_a?(King)
      change_turn
    end

    def setup_board(board)
      board.new(@player1, @player2)
    end
  end

  class ChessPiece
    attr_accessor :status
    attr_reader :owner

    def initialize(owner, name)
      @kill_log = []
      @status = "alive"
      @owner = owner
      @name = name
    end

    def kill(other)
      @kill_log.push(other)
      other.status = "dead"
    end

    def to_s
      @name.to_s
    end

    protected

    def valid_diag_move?(row, col, end_row, end_col, board)
      ((end_row - row).abs == (end_col - col).abs) \
      && clear_path?(row, col, end_row, end_col, board)
    end

    def valid_horz_move?(row, col, end_row, end_col, board)
      (end_row == row) && clear_path?(row, col, end_row, end_col, board)
    end

    def valid_vert_move?(row, col, end_row, end_col, board)
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
        next_cell(row, col, end_row, end_col) => [next_row, next_col]
        clear_path?(next_row, next_col, end_row, end_col, board)
      else
        false
      end
    end
  end

  class Pawn < ChessPiece
    def initialize(owner, front)
      super(owner, "p")
      @first_move = true
      @front = front
    end

    def valid_move?(row, col, end_row, end_col, board)
      return false unless valid_forward_move?(row, end_row)

      if col == end_col # only forward
        valid_dest = board.dig(end_row, end_col).nil?
        @first_move = false if valid_dest
        return valid_dest
      elsif (col - end_col).abs == 1 # diagonal movement
        other_piece = board.dig(end_row, end_col)
        return other_piece && (other_piece.owner != @owner)
      end
      false
    end

    private

    def valid_forward_move?(row, end_row)
      if @first_move
        (row + @front * 2 == end_row) || (row + @front == end_row)
      else
        row + @front == end_row
      end
    end
  end

  class Queen < ChessPiece
    def initialize(owner)
      super(owner, "Q")
    end

    def valid_move?(row, col, end_row, end_col, board)
      valid_diag_move?(row, col, end_row, end_col, board) \
      || valid_horz_move?(row, col, end_row, end_col, board) \
      || valid_vert_move?(row, col, end_row, end_col, board)
    end
  end

  class Rook < ChessPiece
    def initialize(owner)
      super(owner, "R")
    end

    def valid_move?(row, col, end_row, end_col, board)
      valid_horz_move?(row, col, end_row, end_col, board) \
      || valid_vert_move?(row, col, end_row, end_col, board)
    end
  end

  class Bishop < ChessPiece
    def initialize(owner)
      super(owner, "B")
    end

    def valid_move?(row, col, end_row, end_col, board)
      valid_diag_move?(row, col, end_row, end_col, board)
    end
  end

  class King < ChessPiece
    def initialize(owner)
      super(owner, "K")
    end

    def valid_move?(row, col, end_row, end_col, board)
      return false unless (row - end_row).abs == 1 && (col - end_col).abs == 1

      valid_diag_move?(row, col, end_row, end_col, board) \
      || valid_horz_move?(row, col, end_row, end_col, board) \
      || valid_vert_move?(row, col, end_row, end_col, board)
    end
  end

  class Knight < ChessPiece
    def initialize(owner)
      # K was already taken by king, so I had to choose N
      super(owner, "N")
    end

    def valid_move?(row, col, end_row, end_col, board)
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
