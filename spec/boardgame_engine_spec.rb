# frozen_string_literal: true

require 'boardgame_engine'

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
