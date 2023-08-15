#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step hides the Game ActiveReccord objects within their packages
# and exposes needed APIs
#
###############################################################################

bundle install --local
bin/packs add_dependency packs/games_admin packs/teams

mkdir -p packs/games/app/public
mkdir -p packs/games/spec/public

sed -i 's/class_name: "Game"/class_name: "GameRecord"/g' packs/games/app/public/game.rb

mv packs/games/app/public/game.rb packs/games/app/models/game_record.rb
sed -i 's/Game/GameRecord/g' packs/games/app/models/game_record.rb
sed -i 's/:first_team,/:first_team_id,/g' packs/games/app/models/game_record.rb
sed -i 's/:second_team,/:second_team_id,/g' packs/games/app/models/game_record.rb
sed -i '/belongs_to/d' packs/games/app/models/game_record.rb
sed -i '/GameRecord/a\  self.table_name = "games"' packs/games/app/models/game_record.rb
sed -i '$d' packs/games/app/models/game_record.rb
echo '
  sig { returns(T.nilable(Integer)).override }
  def first_team_id
    self[:first_team_id]
  end

  sig { returns(T.nilable(Integer)).override }
  def second_team_id
    self[:second_team_id]
  end

  sig { returns(T.nilable(Integer)).override }
  def winning_team
    self[:winning_team]
  end
end' >> packs/games/app/models/game_record.rb
cat packs/games/app/models/game_record.rb

mv packs/games/spec/public/game_spec.rb packs/games/spec/models/game_record_spec.rb
sed -i 's/Game/GameRecord/g' packs/games/spec/models/game_record_spec.rb
sed -i 's/:first_team }/:first_team_id }/g' packs/games/spec/models/game_record_spec.rb
sed -i 's/:second_team }/:second_team_id }/g' packs/games/spec/models/game_record_spec.rb
sed -i '/belong_to/d' packs/games/spec/models/game_record_spec.rb
cat packs/games/spec/models/game_record_spec.rb

echo '# typed: true
class Game
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  # include HistoricalPerformanceIndicator
  # extend T::Sig

  validates :date, :location, :first_team, :second_team, :winning_team,
            :first_team_score, :second_team_score, presence: true

  attr_reader :id
  attr_accessor :first_team,
    :second_team,
    :winning_team,
    :first_team_score,
    :second_team_score,
    :location,
    :date

  def initialize(
      id,
      first_team,
      second_team,
      winning_team,
      first_team_score,
      second_team_score,
      location,
      date
    )
    @id = id
    @first_team = first_team
    @second_team = second_team
    @winning_team = winning_team
    @first_team_score = first_team_score
    @second_team_score = second_team_score
    @location = location
    @date = date
  end

  def persisted?
    !!id
  end

  def to_hash
    {
      id: @id,
      first_team_id: @first_team.id,
      second_team_id: @second_team.id,
      winning_team: @winning_team,
      first_team_score: @first_team_score,
      second_team_score: @second_team_score,
      location: @location,
      date: @date.to_s
    }
  end

  def ==(other)
    id == other.id &&
      first_team == other.first_team &&
      second_team == other.second_team &&
      winning_team == other.winning_team &&
      first_team_score == other.first_team_score &&
      second_team_score == other.second_team_score &&
      location == other.location &&
      date== other.date
  end

  def first_team_id
    @first_team&.id
  end

  def second_team_id
    @second_team&.id
  end
end
' > packs/games/app/public/game.rb

echo '# typed: false
RSpec.describe Game, type: :model do
  describe "validity" do
    it "can be valid" do
      expect(new_game).to be_valid
    end

    it "is not valid with a nil first_team" do
      expect(new_game(first_team: nil)).to_not be_valid
    end

    it "is not valid with a nil second_team" do
      expect(new_game(second_team: nil)).to_not be_valid
    end

    it "is not valid with a nil winning_team" do
      expect(new_game(winning_team: nil)).to_not be_valid
    end

    it "is not valid with a nil first_team_score" do
      expect(new_game(first_team_score: nil)).to_not be_valid
    end

    it "is not valid with a nil second_team_score" do
      expect(new_game(second_team_score: nil)).to_not be_valid
    end

    it "is not valid with a nil location" do
      expect(new_game(location: nil)).to_not be_valid
    end

    it "is not valid with a nil date" do
      expect(new_game(date: nil)).to_not be_valid
    end
  end

  describe "simple instance methods" do
    it "(they) do what you expect" do
      team1 = create_team
      team2 = create_team
      game = new_game(
        id: 7,
        first_team_id: team1.id,
        second_team_id: team2.id,
        winning_team: 2,
        first_team_score: 2,
        second_team_score: 3,
        location: "Somewhere",
        date: Date.today
      )
      expect(game.id).to eq(7)
      expect(game.first_team_id).to eq(team1.id)
      expect(game.second_team_id).to eq(team2.id)
      expect(game.winning_team).to eq(2)
      expect(game.first_team_score).to eq(2)
      expect(game.second_team_score).to eq(3)
      expect(game.location).to eq("Somewhere")
      expect(game.date).to eq(Date.today)
    end
  end

  describe "#persisted?" do
    it "is true with an id" do
      expect(new_game(id: 8).persisted?).to eq(true)
    end

    it "is false without an id" do
      expect(new_game(id: nil).persisted?).to eq(false)
    end
  end

  describe "#to_hash" do
    it "hashes based on params" do
      team1 = create_team
      team2 = create_team
      game = new_game(
        id: 7,
        first_team_id: team1.id,
        second_team_id: team2.id,
        winning_team: 2,
        first_team_score: 2,
        second_team_score: 3,
        location: "Somewhere",
        date: Date.today
      )
      expect(game.to_hash).to eq(
        {
          date: Date.today.to_s,
          first_team_id: team1.id,
          first_team_score: team2.id,
          id: 7,
          location: "Somewhere",
          second_team_id: 2,
          second_team_score: 3,
          winning_team: 2
        }
      )
    end
  end

  # TODO: needs to be fixed analogous to Team
  describe "#==" do
    it "returns true for objects with the same attributes" do
      game1 = new_game(first_team_id: 1, second_team_id: 2)
      game2 = new_game(first_team_id: 1, second_team_id: 2)
      expect(game1 == game2).to eq(true)
    end

    it "returns false for objects with different attributes" do
      game1 = new_game(id: 1, first_team_id: 1, second_team_id: 2)
      game2 = new_game(id: 5, first_team_id: 1, second_team_id: 2)
      expect(game1 == game2).to eq(false)
    end
  end
end
' > packs/games/spec/public/game_spec.rb

echo '# typed: false
class GameRepository
  def self.get(id)
    game_record = GameRecord.find_by_id(id)
    return nil unless game_record
    record_to_game(game_record)
  end

  def self.list
    GameRecord.all.map { |game_record| record_to_game(game_record) }
  end

  def self.add(game)
    game_record = GameRecord.create(game.to_hash)
    game = record_to_game(game_record)
    game.instance_variable_set(:"@errors", game_record.errors)
    game
  end

  def self.edit(game)
    game_record = GameRecord.find_by_id(game.id)
    return false unless game_record
    game_record.update(game.to_hash)
    game = record_to_game(game_record)
    game.instance_variable_set(:"@errors", game_record.errors)
    game
  end

  def self.delete(game)
    GameRecord.delete(game.id)
  end

  def self.count
    GameRecord.count
  end

  def self.record_to_game(r)
    Game.new(
      r.id,
      TeamRepository.get(r.first_team_id),
      TeamRepository.get(r.second_team_id),
      r.winning_team,
      r.first_team_score,
      r.second_team_score,
      r.location,
      r.date
    )
  end
  private_class_method :record_to_game
end
' > packs/games/app/public/game_repository.rb

echo '# typed: false
RSpec.describe GameRepository do
  describe "#get" do
    it "returns a game when found" do
      game = create_game
      expect(GameRepository.get(game.id)).to eq(
        Game.new(
          game.id,
          game.first_team,
          game.second_team,
          game.winning_team,
          game.first_team_score,
          game.second_team_score,
          game.location,
          game.date
        )
      )
    end

    it "returns nil when not found" do
      game = create_game
      expect(GameRepository.get(game.id + 1)).to eq(nil)
    end
  end

  describe "#list" do
    it "returns all games" do
      game1 = create_game
      game2 = create_game
      expect(GameRepository.list).to eq([game1, game2])
    end
  end

  describe "#add and #count and #list" do
    it "adds a new game to the repository which is counted and listed" do
      expect(GameRepository.count).to eq(0)
      expect(GameRepository.list).to eq([])
      GameRepository.add(new_game(id: nil, location: "here"))
      expect(GameRepository.count).to eq(1)
      actual_game = GameRepository.list.first
      expect(actual_game.id).to_not be_nil
      expect(actual_game.location).to eq("here")
    end
  end

  describe "#edit" do
    it "changes a game in the repository when found" do
      game = create_game(location: "alpha")
      new_game = game.dup
      new_game.location = "beta"
      expect(GameRepository.edit(new_game)).to eq(new_game)
      expect(GameRepository.list).to eq([new_game])
    end

    it "does not change a game in the repository when NOT found" do
      game = create_game
      expect(GameRepository.list).to eq([game])
      new_game = new_game(id: game.id + 1)
      expect(GameRepository.edit(new_game)).to eq(false)
      expect(GameRepository.list).to eq([game])
    end

    it "does not change a game in the repository when NOT valid" do
      game = create_game(location: "alpha")
      expect(GameRepository.list).to eq([game])
      new_game = game.dup
      new_game.location = nil
      expect(GameRepository.edit(new_game)).to eq(new_game)
      expect(GameRepository.list).to eq([game])
    end
  end

  describe "#delete" do
    it "removes games from the repository when found" do
      game1 = create_game
      game2 = create_game
      game3 = create_game
      expect(GameRepository.list).to eq([game1, game2, game3])
      expect(GameRepository.delete(game2)).to eq(1)
      expect(GameRepository.list).to eq([game1, game3])
    end

    it "leaves games in the repository when NOT found" do
      game = create_game
      expect(GameRepository.list).to eq([game])
      expect(GameRepository.delete(new_game(id: -1))).to eq(0)
      expect(GameRepository.list).to eq([game])
    end
  end
end
' > packs/games/spec/public/game_repository_spec.rb

echo 'inherit_from: ../../.rubocop.yml

Packs/ClassMethodsAsPublicApis:
  Enabled: false

Packs/RootNamespaceIsPackName:
  Enabled: false

Packs/TypedPublicApis:
  Enabled: false

Packs/DocumentedPublicApis:
  Enabled: false' > packs/games/.rubocop.yml

sed -i 's/Game.all/GameRepository.list/g' packs/prediction_ui/app/controllers/predictions_controller.rb

#TODO: what is the reason we need this?
sed -i '/sig/c\  sig { abstract.returns(T.nilable(Integer)) }' packs/predictor_interface/app/public/historical_performance_indicator.rb

sed -i 's/@games = Game.all/@games = GameRepository.list/g' packs/games_admin/app/controllers/games_controller.rb
sed -i '/@game = Game.new(game_params)/c\    @game = GameRepository.add(Game.new(\
        nil,\
        Team.new(game_params[:first_team_id].to_i, nil),\
        Team.new(game_params[:second_team_id].to_i, nil),\
        game_params[:winning_team],\
        game_params[:first_team_score],\
        game_params[:second_team_score],\
        game_params[:location],\
        game_params[:date]\
      )\
    )' packs/games_admin/app/controllers/games_controller.rb
sed -i 's/@game = Game.new/@game = Game.new(nil, nil, nil, nil, nil, nil, nil, nil)/g' packs/games_admin/app/controllers/games_controller.rb
sed -i 's/if @game.save/if @game.persisted?/g' packs/games_admin/app/controllers/games_controller.rb
sed -i '/if @game.update(game_params)/c\      @game.first_team = TeamRepository.get(game_params[:first_team_id].to_i) if game_params.has_key?("first_team_id")\
      @game.second_team = TeamRepository.get(game_params[:second_team_id].to_i) if game_params.has_key?("second_team_id")\
      @game.winning_team = game_params[:winning_team] if game_params.has_key?("winning_team")\
      @game.first_team_score = game_params[:first_team_score] if game_params.has_key?("first_team_score")\
      @game.second_team_score = game_params[:second_team_score] if game_params.has_key?("second_team_score")\
      @game.location = game_params[:location] if game_params.has_key?("location")\
      @game.date = game_params[:date] if game_params.has_key?("date")\
\
      @game = GameRepository.edit(@game)\
      if @game.errors.empty?' packs/games_admin/app/controllers/games_controller.rb
sed -i 's/@game.destroy/GameRepository.delete(@game)/g' packs/games_admin/app/controllers/games_controller.rb
sed -i 's/@game = Game.find(params\[:id\])/@game = GameRepository.get(params[:id].to_i)/g' packs/games_admin/app/controllers/games_controller.rb
sed -i '/params.require/c\      params[:game].delete(:id) if params[:game].has_key?(:id)\
      params[:game].delete(:first_team) if params[:game].has_key?(:first_team)\
      params[:game].delete(:second_team) if params[:game].has_key?(:second_team)\
      params.require(:game).permit(\
        :date,\
        :location,\
        :first_team_id,\
        :second_team_id,\
        :winning_team,\
        :first_team_score,\
        :second_team_score\
      )' packs/games_admin/app/controllers/games_controller.rb
cat packs/games_admin/app/controllers/games_controller.rb

sed -i "1i # typed: false" packs/games_admin/spec/requests/games_spec.rb
sed -i 's/to change(Game, :count)/to change(GameRepository, :count)/g' packs/games_admin/spec/requests/games_spec.rb
sed -i 's/redirect_to(game_url(Game.last))/redirect_to(game_url(GameRepository.list.last.id))/g' packs/games_admin/spec/requests/games_spec.rb
sed -i '/expect(response).not_to be_successful/a\        expect(response.body).to include("Date can&#39;t be blank")' packs/games_admin/spec/requests/games_spec.rb
sed -i 's/game.reload/game = GameRepository.get(game.id)/g' packs/games_admin/spec/requests/games_spec.rb
cat packs/games_admin/spec/requests/games_spec.rb

sed -i "1i # typed: ignore" packs/games_admin/spec/routing/games_routing_spec.rb

sed -i '/def game_params/,/##/{/## end/!d}' spec/support/object_creation_methods.rb

echo '  def game_params(overrides = {})
    game_defaults = {}
    if overrides.has_key?(:first_team)
      game_defaults[:first_team_id] = overrides.delete(:first_team)&.id
    end
    if overrides.has_key?(:second_team)
      game_defaults[:second_team_id] = overrides.delete(:second_team)&.id
    end
    defaults = {
      id: nil,
      first_team_id: -> { create_team.id },
      second_team_id: -> { create_team.id },
      winning_team: 2,
      first_team_score: 2,
      second_team_score: 3,
      location: "Somewhere",
      date: Date.today
    }.merge(game_defaults)
    evaluate(defaults.merge(overrides))
  end

  def new_game(overrides = {})
    a = game_params(overrides)
    Game.new(
      a[:id],
      TeamRepository.get(a[:first_team_id]),
      TeamRepository.get(a[:second_team_id]),
      a[:winning_team],
      a[:first_team_score],
      a[:second_team_score],
      a[:location],
      a[:date]
    )
  end

  def create_game(overrides = {})
    game = GameRepository.add(new_game(overrides))
    Kernel.raise "Game creation failed" unless game.persisted?
    game
  end

  private

  def counter
    @counter ||= 0
    @counter += 1
  end

  def evaluate(attributes)
    attributes.keys.inject({}) do |memo, key|
      memo[key] = attributes[key]
      memo[key] = attributes[key].call if attributes[key].is_a?(Proc)
      memo
    end
  end
end' >> spec/support/object_creation_methods.rb
