# frozen_string_literal: true

require "./lib/boardgame_engine"

describe BoardGameEngine::Board do
  describe "#display" do
    it "shows 1x1 board" do
      board = BoardGameEngine::Board.new(1, 1)
      expect { board.display }.to output("[ ]\n").to_stdout
    end

    it "shows 4x4 board" do
      board = BoardGameEngine::Board.new(4, 4)
      expect { board.display }.to output("[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end

    it "shows 5x4 board" do
      board = BoardGameEngine::Board.new(5, 4)
      expect { board.display }.to output("[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end

    it "shows 1x9 board" do
      board = BoardGameEngine::Board.new(1, 9)
      expect { board.display }.to output("[ ][ ][ ][ ][ ]" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end
  end
end
