# frozen_string_literal: true

require "boardgame_engine"

describe BoardgameEngine::Board do
  describe "#display" do
    it "shows 1x1 board" do
      board = BoardgameEngine::Board.new(1, 1)
      expect { board.display }.to output("[ ]\n").to_stdout
    end

    it "shows 4x4 board" do
      board = BoardgameEngine::Board.new(4, 4)
      expect { board.display }.to output("[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end

    it "shows 5x4 board" do
      board = BoardgameEngine::Board.new(5, 4)
      expect { board.display }.to output("[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end

    it "shows 1x9 board" do
      board = BoardgameEngine::Board.new(1, 9)
      expect { board.display }.to output("[ ][ ][ ][ ][ ]" \
                                         "[ ][ ][ ][ ]\n").to_stdout
    end
  end
end

describe SampleChess::ChessBoard do
  describe "#display" do
    it "shows starting board" do
      board = SampleChess::ChessBoard.new("p1", "p2")
      expect { board.display }.to output("0 [R][N][B][Q][K][B][N][R]\n" \
                                         "1 [p][p][p][p][p][p][p][p]\n" \
                                         "2 [ ][ ][ ][ ][ ][ ][ ][ ]\n" \
                                         "3 [ ][ ][ ][ ][ ][ ][ ][ ]\n" \
                                         "4 [ ][ ][ ][ ][ ][ ][ ][ ]\n" \
                                         "5 [ ][ ][ ][ ][ ][ ][ ][ ]\n" \
                                         "6 [p][p][p][p][p][p][p][p]\n" \
                                         "7 [R][N][B][K][Q][B][N][R]\n" \
                                         "   0  1  2  3  4  5  6  7 \n").to_stdout
    end
  end
end

describe BoardgameEngine::Boardgame do
  describe "#tutorial" do
    it "displays tutorial text in the command line before input" do
      game = BoardgameEngine::Boardgame.new(BoardgameEngine::Board, "Test Instructions")
      expect { game.tutorial }.to output("Test Instructions\n").to_stdout
    end
  end
end
