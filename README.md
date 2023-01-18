# BoardgameEngine

A gem that provides a template for creating boardgames. It aims to streamline
the process of making boardgames to be played on the terminal by providing a 
variety of classes and modules.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add boardgame_engine

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install boardgame_engine

## Usage
### Initial Setup
To start making your own boardgame using this gem, your game module needs at least two classes -
a `Game` class inheriting from `Boardgame` and a `Board` class inheriting `Board`.
`Game` captures the core gameplay loop/logic and the `Board` captures 
interactions with the board.

Depending on the game rules, select child modules from the `Games` and `Boards`
and include it into the `Game` and `Board` class respectively.
These modules will handle much of the game and board logic related to the
game mechanic/rule.

For example, if the turns in your game go in a cycle like 1 -> 2 -> 3 -> 1 -> 2 ...
your `Game` class would look like
```ruby
class Game < BoardgameEngine::Game
  include Games::CyclicalGame
  NUM_PLAYERS = 3
  ...
end
```
Including this module makes it so that the `BoardgameEngine::Game#change_turn` 
method automatically hands the turn over to the correct player.

### Overriding
At the current stage of the app, there are methods that necessarily must be
overridden in the child class.
`play_turn` must be implemented on _your_ `Game` class, and must contain what happens
during a single turn (not a round, just a turn).

Additionally, the limited number of modules mean that you will probably have to implement some
methods on your own. I hope to reduce the number of these as the app matures.
I left yard comments on all module methods, so hopefully overriding won't be too
difficult.

## Example Games
Check out `connect4.rb` for a game built with rather minimal overrides and
`chess.rb` for a game that makes heavy use of customization.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports are welcome on GitHub at https://github.com/Forthoney/boardgame_engine.
I may not get to them quickly but it will be greatly helpful

As the app is under heavy development I will not look deeply into actually 
pulling pull requests (if there were to be any).
I will definitely consider the ideas proposed in them, so they are still welcome.
