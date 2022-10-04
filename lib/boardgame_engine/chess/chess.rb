# frozen_string_literal: true

require_relative '../boardgame'
require_relative '../multiplayergame'
require_relative 'chess_pieces'

INSTRUCTIONS = "You can select spots on the board by inputting the row and \
column with a comma in between. See example below\n1, 1\n"

class ChessBoard < Board
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

class Chess < Boardgame
  include TwoPlayers

  def initialize(name1 = 'Player 1', name2 = 'Player 2')
    super(ChessBoard, INSTRUCTIONS, name1, name2)
  end

  def to_s
    super('chess')
  end

  private

  def valid_input?(input)
    coords = input.split(',')
    coords.all? { |c| c.match?(/[[:digit:]]/) && c.to_i.between?(0, 7) }
  end

  def valid_piece?(piece)
    !piece.nil? && piece.owner == @turn
  end

  def select_piece
    input = proper_format_input
    input.split(',').map(&:to_i) => [row, col]
    if valid_piece? @board.board.dig(row, col)
      [row, col]
    else
      puts 'Invalid piece. Try again'
      select_piece
    end
  end

  def select_destination(piece, row, col)
    input = proper_format_input(['back'])
    return 'back' if input == 'back'

    input.split(',').map(&:to_i) => [end_row, end_col]
    if piece.valid_move?(row, col, end_row, end_col, @board.board)
      [end_row, end_col]
    else
      puts 'Invalid destination. Try again'
      select_destination(piece, row, col)
    end
  end

  def play_turn
    puts "#{@turn}'s turn\nSelect your piece"
    select_piece => [row, col]
    piece = @board.board[row][col]
    puts "Select where to move #{piece} to. Type back to reselect piece"
    dest = select_destination(piece, row, col)
    return if dest == 'back'

    killed = @board.move_piece(row, col, dest[0], dest[1])
    @winner = piece.owner if killed.is_a?(King)
    change_turn
  end

  def setup_board(board)
    board.new(@player1, @player2)
  end
end

Chess.play