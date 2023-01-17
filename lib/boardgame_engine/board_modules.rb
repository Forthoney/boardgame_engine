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

    def valid_board_input?(input)
      input.match?(/[0-#{@board.length - 1}], [0-#{@board[0].length - 1}]$/)
    end

    def parse_input(input)
      input.split(',').map(&:to_i)
    end

    private

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
