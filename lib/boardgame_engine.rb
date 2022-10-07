# frozen_string_literal: true

require_relative "boardgame_engine/version"

require "boardgame_engine/boardgame"
require "boardgame_engine/multiplayergame"
require "boardgame_engine/sample_games"

module BoardgameEngine
  class Error < StandardError; end
end
