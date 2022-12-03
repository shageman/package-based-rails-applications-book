
require_relative "../../packages/games/spec/support/games_creation_methods"
require_relative "../../packages/teams/spec/support/teams_creation_methods"

module ObjectCreationMethods
  include GamesCreationMethods
  include TeamsCreationMethods
end

