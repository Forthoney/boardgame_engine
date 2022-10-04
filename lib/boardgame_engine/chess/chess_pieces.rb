class ChessPiece
  attr_accessor :status
  attr_reader :owner

  def initialize(owner, name)
    @kill_log = []
    @status = 'alive'
    @owner = owner
    @name = name
  end

  def kill(other)
    @kill_log.push(other)
    other.status = 'dead'
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

    if end_col != col
      col_move = (end_col - col) / (end_col - col).abs
    end
    if end_row != row
      row_move = (end_row - row) / (end_row - row).abs
    end

    [row + row_move, col + col_move]
  end

  def clear_path?(row, col, end_row, end_col, board)
    current_tile = board.dig(row, col)
    if (row == end_row) && (col == end_col)
      current_tile.nil? || (current_tile.owner != self.owner)
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
    super(owner, 'p')
    @first_move = true
    @front = front
  end

  def valid_move?(row, col, end_row, end_col, board)
    return false unless valid_forward_move?(row, end_row)

    if col == end_col # only forward
      result = board.dig(end_row, end_col).nil?
      @first_move = false if result
      result
    elsif (col - end_col).abs == 1 # diagonal movement
      other_piece = board.dig(end_row, end_col)
      other_piece && (other_piece.owner != @owner)
    else
      false
    end
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
    super(owner, 'Q')
  end

  def valid_move?(row, col, end_row, end_col, board)
    valid_diag_move?(row, col, end_row, end_col, board) \
    || valid_horz_move?(row, col, end_row, end_col, board) \
    || valid_vert_move?(row, col, end_row, end_col, board)
  end
end

class Rook < ChessPiece
  def initialize(owner)
    super(owner, 'R')
  end

  def valid_move?(row, col, end_row, end_col, board)
    valid_horz_move?(row, col, end_row, end_col, board) \
    || valid_vert_move?(row, col, end_row, end_col, board)
  end
end

class Bishop < ChessPiece
  def initialize(owner)
    super(owner, 'B')
  end

  def valid_move?(row, col, end_row, end_col, board)
    valid_diag_move?(row, col, end_row, end_col, board)
  end
end

class King < ChessPiece
  def initialize(owner)
    super(owner, 'K')
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
    #K was already taken by king, so I had to choose N
    super(owner, 'N')
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
    return spot.nil? || spot.owner != self.owner
  end
end
