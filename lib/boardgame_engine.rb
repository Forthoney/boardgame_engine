# frozen_string_literal: true

require_relative "boardgame_engine/version"

module BoardgameEngine
  require "boardgame_engine/boardgame"
  require "boardgame_engine/multiplayergame"
end

module SampleGames
  require "boardgame_engine/chess/chess"
  require "boardgame_engine/connect4/connect4"
end
