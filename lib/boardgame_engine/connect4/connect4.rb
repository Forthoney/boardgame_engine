# frozen_string_literal: true

require "./lib/boardgame_engine"

class Connect4Board < BoardgameEngine::Board
  def initialize
    super(6, 7)
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
end

class Connect4 < BoardgameEngine::Boardgame
  include TwoPlayers

  INSTRUCTIONS = "You can select which column to drop you chip into by typing" \
  " in the row number."

  def initialize(name1 = "Player 1", name2 = "Player 2")
    super(Connect4Board, INSTRUCTIONS, name1, name2)
  end

  def to_s
    super("connect-four")
  end

  private

  def valid_input?(input)
    input.match?(/[[:digit:]]/) && input.to_i.between?(0, 6)
  end

  def play_turn
    puts "#{@turn}'s turn. Choose a column to drop your chip in"
    col = proper_format_input.to_i
    @board.drop_chip(col, @turn)
    @winner = @turn if win?
    change_turn
  end

  def win?
    [@board.board,
     @board.board.transpose,
     align_diagonally(@board.board),
     align_diagonally(@board.board.transpose)].each do |config|
      config.each { |direction| return true if four_in_a_row? direction }
    end
    false
  end

  def four_in_a_row?(row)
    counts = row.chunk { |x| x }.map { |x, xs| [x, xs.length] }
    return true if counts.any? { |x, count| count > 3 && !x.nil? }
  end

  def align_diagonally(board)
    board.map.with_index do |row, idx|
      left_filler = Array.new(board.length - 1 - idx, nil)
      right_filler = Array.new(idx, nil)
      left_filler + row + right_filler
    end
  end
end
