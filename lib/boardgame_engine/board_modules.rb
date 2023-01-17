# frozen_string_literal: true

# Module for different board types
module Boards
  # Boards laid out in grid format
  module Grid
    # Make a 2D Array representing the board
    #
    # @param [Integer] row the number of rows
    # @param [Integer] col the number of columns
    #
    # @return [Array<Array>] A 2D Array
    def generate_board(row, col)
      Array.new(row) { Array.new(col) { nil } }
    end

    # Print a visual representation of the 
    #
    # @param [Boolean] show_row whether to show row labels
    # @param [Boolean] show_col whether to show column labels
    #
    # @return [void]
    def display(show_row: false, show_col: false)
      if show_row
        @board.each_with_index { |row, idx| puts("#{idx} " + format_row(row)) }
      else
        @board.each { |row| puts format_row(row) }
      end

      return unless show_col

      column_spacer = show_row ? '  ' : ''
      puts format_col(column_spacer)
    end

    def get_piece_at(location)
      row, col = location
      @board.dig(row, col)
    end

    def set_piece_at(location, piece)
      row, col = location
      @board[row][col] = piece
    end

    def valid_board_input?(input, only_row: false, only_col: false)
      if only_row || only_col
        input.match?(/[0-#{@board.length - 1}]/)
      else
        input.match?(/[0-#{@board.length - 1}], [0-#{@board[0].length - 1}]$/)
      end
    end

    def parse_input(input)
      input.split(',').map(&:to_i)
    end

    def consecutive?(row: true, col: true, diagonal: true)
      configs = []
      configs << @board if row
      configs << @board.transpose if col
      configs << align_diagonal(@board) << align_diagonal(@board.transpose) if diagonal

      configs.each do |board|
        board.each { |array| return true if row_consecutive?(4, array) }
      end
      false
    end

    private

    def row_consecutive?(num, array)
      elem_counts = array.chunk { |x| x }.map { |x, xs| [x, xs.length] }
      elem_counts.any? { |x, count| count >= num && x }
    end

    def align_diagonal(board)
      board.map.with_index do |row, idx|
        left_filler = Array.new(board.length - 1 - idx, nil)
        right_filler = Array.new(idx, nil)
        left_filler + row + right_filler
      end
    end

    def format_row(row)
      row.map { |elem| "[#{elem.nil? ? ' ' : elem}]" }.join
    end

    def format_col(column_spacer)
      @board[0].each_index.reduce(column_spacer) { |str, idx| str + " #{idx} " }
    end
  end

  # Boards with movable pieces
  module MovablePiece
    def move_piece(start_location, end_location, set_start_to: nil)
      piece = get_piece_at(start_location)
      set_piece_at(start_location, set_start_to)
      destination_piece = get_piece_at(end_location)
      set_piece_at(end_location, piece)

      destination_piece
    end
  end
end
