# frozen_string_literal: true

# All classes in this script are intended to be abstract, meaning they should
# not be called on their own.

# Class representing a physical board comprised of a grid in a board game. It
# acts as both the View and Model if the project were to be compared to a MVC
# model. It plays both roles as the board in a board game not only stores data,
# but also IS the data that must be shown to the players.
class Board
  attr_reader :board

  def initialize(row, col)
    @board = Array.new(row) { Array.new(col) { nil } }
  end

  def display(show_row: false, show_col: false)
    if show_row
      @board.each_with_index { |row, idx| puts("#{idx} " + format_row(row)) }
    else
      @board.each { |row| puts format_row(row) }
    end
    return unless show_col

    column_spacer = show_row ? "  " : ""
    puts(@board[0].each_index.reduce(column_spacer) do |str, idx|
      str + " #{idx} "
    end)
  end

  def move_piece(start_row, start_col, end_row, end_col)
    piece = @board[start_row][start_col]
    @board[start_row][start_col] = nil
    destination = @board[end_row][end_col]
    @board[end_row][end_col] = piece

    destination
  end

  private

  def format_row(row)
    row.map { |elem| "[#{elem.nil? ? " " : elem}]" }.join
  end

  def spot_playable?(piece, row, col)
    piece.possible_moves.include? [row, col]
  end
end

# Class representing a player in a game
class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def to_s
    @name.to_s
  end
end

# Class for running a board game.
class Boardgame
  EXIT_INSTRUCTIONS ||= "Try a sample input or input 'back' to leave the " \
  "tutorial. Type in 'exit' anytime to exit the game fully"

  def initialize(board, instructions, name1 = "Player 1", name2 = "Player 2")
    @player1 = Player.new(name1)
    @player2 = Player.new(name2)
    @board = setup_board(board)
    @instructions = instructions
    @winner = nil
  end

  def self.play(do_onboarding: true)
    puts "What is Player 1's name?"
    player1 = gets.chomp
    puts "What is Player 2's name?"
    player2 = gets.chomp
    @game = new(player1, player2)

    puts "Welcome to #{@game}!"
    @game.onboarding if do_onboarding
    puts "Starting #{@game}..."
    @game.start
  end

  def to_s(game_name = "boardgame")
    "#{game_name} between #{@player1} and #{@player2}"
  end

  def onboarding
    puts "Would you like a tutorial on how to play on this program? \n(y, n)"
    case gets.chomp
    when "y"
      tutorial
    when "n"
      puts "Skipping tutorial"
    else
      puts 'Please answer either "y" or "n"'
      onboarding
    end
  end

  def tutorial
    puts @instructions + Boardgame::EXIT_INSTRUCTIONS
    input = gets.chomp
    until input == "back"
      exit if input == "exit"
      puts valid_input?(input) ? "Valid input!" : "Invalid input"
      input = gets.chomp
    end
  end

  def start(turn = @player1)
    @turn = turn
    @board.display
    until @winner
      play_turn
      @board.display
    end
    puts "#{@winner} wins!"
  end

  protected

  def proper_format_input(special_commands = [])
    input = gets.chomp
    until valid_input?(input)
      exit if input == "exit"
      return input if special_commands.include?(input)

      puts "Input is in the wrong format or out of bounds. Try again"
      input = gets.chomp
    end
    input
  end

  def setup_board(board)
    board.new
  end
end
