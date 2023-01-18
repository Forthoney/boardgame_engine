# frozen_string_literal: true

# Module for different board types
module Boards
  # Boards laid out in grid format
  module Grid
    # Print a visual representation of the board
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
      puts format_col_numbering(column_spacer)
    end

    # Accessor for getting piece at a location on the board
    #
    # @param [Array<Integer, Integer>] location the coordinates on the grid to
    # get the piece from
    #
    # @return [Piece] the piece at the location
    def get_piece_at(location)
      row, col = location
      @board.dig(row, col)
    end

    # Setter for setting a piece at a location on the board
    #
    # @param [Array<Integer, Integer>] location <description>
    # @param [Piece] piece the piece to place down
    #
    # @return [void]
    def set_piece_at(location, piece)
      row, col = location
      @board[row][col] = piece
    end

    # Check whether the given input refers to a valid location on the board,
    # regardless of placement of other pieces, rules, etc
    #
    # @param [String] input the user input
    # @param [Boolean] only_row optional arg for only allowing user to specify
    # row
    # @param [Boolean] only_col optional arg for only allowing user to specify
    # col
    #
    # @return [Boolean] true if the input can be parsed into a location on the
    # board, false otherwise
    def valid_board_input?(input, only_row: false, only_col: false)
      if only_row || only_col
        input.match?(/[0-#{@board.length - 1}]/)
      else
        input.match?(/[0-#{@board.length - 1}], [0-#{@board[0].length - 1}]$/)
      end
    end

    # Check whether there exists a clear diagonal path from start to a
    # destination
    #
    # @param [Array<Integer, Integer>] start_location the start location
    # @param [Array<Integer, Integer>] end_location the intended destination
    #
    # @return [Boolean] true if there exists an unblocked path to destination
    def clear_diag_path?(start_location, end_location)
      row, col = start_location
      end_row, end_col = end_location

      ((end_row - row).abs == (end_col - col).abs) \
      && clear_path?(row, col, end_row, end_col, board)
    end

    # Check whether there exists an unblocked horizontal path from start to
    # a destination
    #
    # @param [Array<Integer, Integer>] start_location the start location
    # @param [Array<Integer, Integer>] end_location the intended destination
    #
    # @return [Boolean] true if there exists an unblocked path to destination
    def clear_horz_path?(start_location, end_location)
      row, col = start_location
      end_row, end_col = end_location

      (end_row == row) && clear_path?(row, col, end_row, end_col, board)
    end

    # Check whether there exists an unblocked vertical path from start to
    # a destination
    #
    # @param [Array<Integer, Integer>] start_location the start location
    # @param [Array<Integer, Integer>] end_location the intended destination
    #
    # @return [Boolean] true if there exists an unblocked path to destination
    def clear_vert_path?(start_location, end_location)
      row, col = start_location
      end_row, end_col = end_location

      (end_col == col) && clear_path?(row, col, end_row, end_col, board)
    end

    # Parse an input from the user that has a corresponding board location. This
    # must be used in after valid_board_input? has confirmed the input is in
    # the correct format
    #
    # @param [String] input a valid
    #
    # @return [Array<Integer, Integer>]
    def parse_input(input)
      input.split(',').map(&:to_i)
    end

    protected

    # Make a 2D Array representing the board
    #
    # @param [Integer] row the number of rows
    # @param [Integer] col the number of columns
    #
    # @return [Array<Array>] A 2D Array
    def generate_board(row, col)
      Array.new(row) { Array.new(col) { nil } }
    end

    # Check whether there are consecutive pieces on the board
    #
    # @param [Integer] num the number of consecutive pieces to check for.
    # @param [Boolean] row check for row-wise consecutive pieces
    # @param [Boolean] col check for column-wise consecutive pieces
    # @param [Boolean] diagonal check for diagonally consecutive pieces
    #
    # @return [Boolean] true if any specified directins have num number of
    # consecutive pieces
    def consecutive?(num, row: true, col: true, diagonal: true)
      configs = []
      configs << @board if row
      configs << @board.transpose if col
      configs << align_diagonal(@board) << align_diagonal(@board.transpose) if diagonal

      configs.each do |board|
        board.each { |array| return true if row_consecutive?(num, array) }
      end
      false
    end

    private

    # calculates the location of the next cell in the sequence of cells from a
    # given start location and an end location
    #
    # @param [Integer] row
    # @param [Integer] col
    # @param [Integer] end_row
    # @param [Integer] end_col
    #
    # @return [Array<Integer, Integer>] the next cell in the sequence of cells
    def next_cell(row, col, end_row, end_col)
      row_move = 0
      col_move = 0

      col_move = (end_col - col) / (end_col - col).abs if end_col != col
      row_move = (end_row - row) / (end_row - row).abs if end_row != row

      [row + row_move, col + col_move]
    end

    # Given a linear path, check whether there exists an unblocked path.
    # It msut be checked beforehand that the path is indeed linear
    #
    # @param [Integer] row
    # @param [Integer] col
    # @param [Integer] end_row
    # @param [Integer] end_col
    #
    # @return [Boolean] true if there exists a clear path
    def clear_path?(row, col, end_row, end_col)
      current_tile = get_piece_at([row, col])

      if (row == end_row) && (col == end_col)
        current_tile.nil? || (current_tile.owner != @owner)
      elsif current_tile.nil? || current_tile.equal?(self)
        next_row, next_col = next_cell(row, col, end_row, end_col)
        clear_path?(next_row, next_col, end_row, end_col)
      else
        false
      end
    end

    # Check a single row for consecutive pieces
    #
    # @param [Integer] num the number of consecutive pieces to check for
    # @param [Array] array the row to check in
    #
    # @return [Boolean] true if there are at least num number of consecutive
    # elements
    def row_consecutive?(num, array)
      chunked_elems = array.chunk { |elem| elem }
      elem_counts = chunked_elems.map { |elem, elems| [elem, elems.length] }
      elem_counts.any? { |elem, count| count >= num && elem }
    end

    # Align the diagonals of a board. Must be called once on the original board
    # and once more on the transposed board to check for both directions of
    # diagonals
    #
    # @param [Array<Array>] board the board to align
    #
    # @return [Array<Array>] new board with the diagonals aligned
    def align_diagonal(board)
      board.map.with_index do |row, idx|
        left_filler = Array.new(board.length - 1 - idx, nil)
        right_filler = Array.new(idx, nil)
        left_filler + row + right_filler
      end
    end

    # Format a single row for String representation
    #
    # @param [Array] row the row to turn into a String
    #
    # @return [String] a String representation of the row
    def format_row(row)
      row.map { |elem| "[#{elem.nil? ? ' ' : elem}]" }.join
    end

    # Format the column numbering of a board
    #
    # @param [String] column_spacer the spacer to use between the indices
    #
    # @return [String] a String representation of the row
    def format_col_numbering(column_spacer)
      @board[0].each_index.reduce(column_spacer) { |str, idx| str + " #{idx} " }
    end
  end

  # Boards with movable pieces
  module MovablePiece
    # Move a piece from at a start location to an end location. Should be called
    # after checking that the movement is valid board and game logic wise.
    #
    # @param [<Type>] start_location the starting location of the piece
    # @param [<Type>] end_location the destination of the piece
    # @param [<Type>] set_start_to what to place at the start location. defaults
    # to nil
    #
    # @return [Piece] the piece at the destination
    def move_piece(start_location, end_location, set_start_to: nil)
      piece = get_piece_at(start_location)
      set_piece_at(start_location, set_start_to)
      destination_piece = get_piece_at(end_location)
      set_piece_at(end_location, piece)

      destination_piece
    end
  end
end
