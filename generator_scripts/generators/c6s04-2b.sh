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

rm packages/games/app/models/game.rb
rm packages/games/app/models/game.rbi
rm packages/games/deprecated_references.yml
rm packages/games/spec/models/game_spec.rb

mkdir -p packages/games/app/public/
mkdir -p packages/games/spec/public/
echo '# typed: false
class GameRecord < ApplicationRecord
  self.table_name = "games"

  include HistoricalPerformanceIndicator
  extend T::Sig

  validates :date, :location, :first_team_id, :second_team_id, :winning_team,
            :first_team_score, :second_team_score, presence: true
end
' > packages/games/app/models/game_record.rb

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
' > packages/games/app/public/game_repository.rb

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
' > packages/games/app/public/game.rb

echo '# typed: false
RSpec.describe GameRecord do
  it { should validate_presence_of :date }
  it { should validate_presence_of :location }
  it { should validate_presence_of :first_team_id }
  it { should validate_presence_of :second_team_id }
  it { should validate_presence_of :winning_team }
  it { should validate_presence_of :first_team_score }
  it { should validate_presence_of :second_team_score }

  # it { should belong_to :first_team}
  # it { should belong_to :second_team}
end
' > packages/games/spec/models/game_record_spec.rb

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
    it "adds a new game to the repository" do
      expect(GameRepository.count).to eq(0)
      expect(GameRepository.list).to eq([])
      GameRepository.add(new_game(id: nil, location: 'here'))
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
' > packages/games/spec/public/game_repository_spec.rb

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
' > packages/games/spec/public/game_spec.rb

echo '# typed: false
class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy ]

  # GET /games or /games.json
  def index
    @games = GameRepository.list
  end

  # GET /games/1 or /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new(nil, nil, nil, nil, nil, nil, nil, nil)
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games or /games.json
  def create
    @game = GameRepository.add(Game.new(
        nil,
        Team.new(game_params[:first_team_id], nil),
        Team.new(game_params[:second_team_id], nil),
        game_params[:winning_team],
        game_params[:first_team_score],
        game_params[:second_team_score],
        game_params[:location],
        game_params[:date]
      )
    )

    respond_to do |format|
      if @game.persisted?
        format.html { redirect_to game_url(@game), notice: "Game was successfully created." }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    respond_to do |format|
      @game.first_team = TeamRepository.get(game_params[:first_team_id]) if game_params.has_key?("first_team_id")
      @game.second_team = TeamRepository.get(game_params[:second_team_id]) if game_params.has_key?("second_team_id")
      @game.winning_team = game_params[:winning_team] if game_params.has_key?("winning_team")
      @game.first_team_score = game_params[:first_team_score] if game_params.has_key?("first_team_score")
      @game.second_team_score = game_params[:second_team_score] if game_params.has_key?("second_team_score")
      @game.location = game_params[:location] if game_params.has_key?("location")
      @game.date = game_params[:date] if game_params.has_key?("date")

      @game = GameRepository.edit(@game)
      if @game.errors.empty?
        format.html { redirect_to game_url(@game), notice: "Game was successfully updated." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    GameRepository.delete(@game)

    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = GameRepository.get(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params[:game].delete(:id) if params[:game].has_key?(:id)
      params[:game].delete(:first_team) if params[:game].has_key?(:first_team)
      params[:game].delete(:second_team) if params[:game].has_key?(:second_team)
      params.require(:game).permit(
        :date,
        :location,
        :first_team_id,
        :second_team_id,
        :winning_team,
        :first_team_score,
        :second_team_score
      )
    end
end
' > packages/games_admin/app/controllers/games_controller.rb

echo '# typed: false
# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we"re
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/games", type: :request do
  let(:team1) { create_team(name: "Team1") }
  let(:team2) { create_team(name: "Team2") }

  # Game. As you add validations to Game, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    game_params(first_team: team1, second_team: team2)
  }

  let(:invalid_attributes) {
    game_params(first_team: team1, second_team: team2, date: nil)
  }

  describe "GET /index" do
    it "renders a successful response" do
      create_game valid_attributes
      get games_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      game = create_game valid_attributes
      get game_url(game)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_game_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      game = create_game valid_attributes
      get edit_game_url(game)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Game" do
        expect {
          post games_url, params: { game: valid_attributes }
        }.to change(GameRepository, :count).by(1)
      end

      it "redirects to the created game" do
        post games_url, params: { game: valid_attributes }
        expect(response).to redirect_to(game_url(GameRepository.list.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Game" do
        expect {
          post games_url, params: { game: invalid_attributes }
        }.to change(GameRepository, :count).by(0)
      end

      it "renders a successful response (i.e. to display the new template)" do
        post games_url, params: { game: invalid_attributes }
        expect(response).not_to be_successful
        expect(response.body).to include("Date can&#39;t be blank")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { location: "test" }
      }

      it "updates the requested game" do
        game = create_game valid_attributes
        patch game_url(game), params: { game: new_attributes }
        game = GameRepository.get(game.id)
        expect(game.location).to eq("test")
      end

      it "redirects to the game" do
        game = create_game valid_attributes
        patch game_url(game), params: { game: new_attributes }
        game = GameRepository.get(game.id)
        expect(response).to redirect_to(game_url(game))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the edit template)" do
        game = create_game valid_attributes
        patch game_url(game), params: { game: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.body).to include("Date can&#39;t be blank")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested game" do
      game = create_game valid_attributes
      expect {
        delete game_url(game)
      }.to change(GameRepository, :count).by(-1)
    end

    it "redirects to the games list" do
      game = create_game valid_attributes
      delete game_url(game)
      expect(response).to redirect_to(games_url)
    end
  end
end
' > packages/games_admin/spec/requests/games_spec.rb

echo '# typed: ignore
class PredictionsController < ApplicationController
  def new
    @teams = TeamRepository.list
  end

  def create
    predictor = Predictor.new
    predictor.learn(TeamRepository.list, GameRepository.list)
    @prediction = predictor.predict(
        TeamRepository.get(params["first_team"]["id"]),
        TeamRepository.get(params["second_team"]["id"]))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '# typed: false
RSpec.describe "the prediction process", type: :system do
  before :each do
    team1 = create_team name: "UofL"
    team2 = create_team name: "UK"

    create_game first_team: team1, second_team: team2, winning_team: 1
    create_game first_team: team2, second_team: team1, winning_team: 2
    create_game first_team: team2, second_team: team1, winning_team: 2
  end

  it "get a new prediction" do
    visit "/"

    click_link "Predictions"

    select "UofL", from: "First team"
    select "UK", from: "Second team"
    click_button "What is it going to be"

    expect(page).to have_content "the winner will be UofL"
  end
end
' > packages/prediction_ui/spec/system/predictions_spec.rb

echo '# typed: false

require "saulabs/trueskill"

class Predictor
  include PredictorInterface
  extend T::Sig

  sig {override.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void}
  def learn(teams, games)
    @teams_lookup = T.let({}, T.nilable(T::Hash[Integer, TeamLookup]))
    @teams_lookup = teams.inject({}) do |memo, team|
      memo[team.id] = TeamLookup.new(
        team: team,
        rating: Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)
      )
      memo
    end

    games.each do |game|
      first_team_rating = @teams_lookup[game.first_team.id].rating
      second_team_rating = @teams_lookup[game.second_team.id].rating
      game_result = game.winning_team == 1 ?
          [[first_team_rating], [second_team_rating]] :
          [[second_team_rating], [first_team_rating]]
        Saulabs::TrueSkill::FactorGraph.new(game_result, [1, 2]).update_skills
    end
  end

  sig {override.params(first_team: Contender, second_team: Contender).returns(Prediction)}
  def predict(first_team, second_team)
    team1 = T.must(T.must(@teams_lookup)[first_team.id]).team
    team2 = T.must(T.must(@teams_lookup)[second_team.id]).team
    winner = higher_mean_team(first_team, second_team) ? team1 : team2
    Prediction.new(team1, team2, winner)
  end

  private

  sig {params(first_team: Contender, second_team: Contender).returns(T::Boolean)}
  def higher_mean_team(first_team, second_team)
    T.must(T.must(@teams_lookup)[first_team.id]).rating.mean >
        T.must(T.must(@teams_lookup)[second_team.id]).rating.mean
  end

  class TeamLookup < T::Struct
    const :team, Contender
    const :rating, Saulabs::TrueSkill::Rating
  end
  private_constant :TeamLookup
end

' > packages/predictor/app/public/predictor.rb

echo '# typed: false
RSpec.describe Predictor do
  before do
    @team1 = create_team name: "A"
    @team2 = create_team name: "B"

    @predictor = Predictor.new
  end

  it "predicts teams that have won in the past to win in the future" do
    game = create_game first_team: @team1, second_team: @team2, winning_team: 1
    @predictor.learn([@team1, @team2], [game])

    prediction = @predictor.predict(@team2, @team1)
    expect(prediction.winner).to eq @team1

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction.winner).to eq @team1
  end

  it "changes predictions based on games learned" do
    game1 = create_game first_team: @team1, second_team: @team2, winning_team: 1
    game2 = create_game first_team: @team1, second_team: @team2, winning_team: 2
    game3 = create_game first_team: @team1, second_team: @team2, winning_team: 2
    @predictor.learn([@team1, @team2], [game1, game2, game3])

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction.winner).to eq @team2
  end

  it "behaves funny when teams are equally strong" do
    @predictor.learn([@team1, @team2], [])

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction).to be_an Prediction
    expect(prediction.first_team).to eq @team1
    expect(prediction.second_team).to eq @team2
    expect(prediction.winner).to eq @team2

    prediction = @predictor.predict(@team2, @team1)
    expect(prediction).to be_an Prediction
    expect(prediction.first_team).to eq @team2
    expect(prediction.second_team).to eq @team1
    expect(prediction.winner).to eq @team1
  end
end
' > packages/predictor/spec/models/predictor_spec.rb

echo '# typed: true
module ObjectCreationMethods
  def team_params(overrides = {})
    defaults = {
      id: nil,
      name: "Some name #{counter}"
    }
    defaults.merge(overrides)
  end

  def new_team(overrides = {})
    a = team_params(overrides)
    Team.new(a[:id], a[:name])
  end

  def create_team(overrides = {})
    team = TeamRepository.add(new_team(overrides))
    Kernel.raise "Team creation failed" unless team.persisted?
    team
  end

  def game_params(overrides = {})
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
end
' > spec/support/object_creation_methods.rb

# sed -i 's/team.reload/team = TeamRepository.get(team.id)/g' packages/teams_admin/spec/requests/teams_spec.rb
# sed -i 's/Team, :count/TeamRepository, :count/g' packages/teams_admin/spec/requests/teams_spec.rb
# sed -i 's/Team.all.last/TeamRecord.all.last/g' packages/teams_admin/spec/requests/teams_spec.rb

bundle install --local

bin/rails sorbet:update:all

