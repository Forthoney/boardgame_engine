module TwoPlayers
  def change_turn
    @turn = @turn == @player1 ? @player2 : @player1
  end
end
