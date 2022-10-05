# frozen_string_literal: true

require_relative "boardgame_engine/version"

require_relative "boardgame_engine/boardgame"
require_relative "boardgame_engine/multiplayergame"
require_relative "boardgame_engine/chess/chess"
require_relative "boardgame_engine/connect4/connect4"

module BoardgameEngine
  class Error < StandardError; end
end
