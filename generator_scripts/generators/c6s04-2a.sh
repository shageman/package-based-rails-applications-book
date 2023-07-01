#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step hides the Team ActiveReccord objects within their packages
# and exposes needed APIs
#
###############################################################################

rm packages/teams/app/models/team.rb
rm packages/teams/spec/models/team_spec.rb

mkdir packages/teams/app/public
mkdir packages/teams/spec/public

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/teams/package.yml

echo '# typed: false
class TeamRecord < ApplicationRecord
  self.table_name = "teams"

  include Contender
  extend T::Sig

  validates :name, presence: true
end
' > packages/teams/app/models/team_record.rb

echo '# typed: false
RSpec.describe TeamRecord do
  it { should validate_presence_of :name }
end
' > packages/teams/spec/models/team_record_spec.rb

echo '# typed: strict
class Team
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  include Contender
  extend T::Sig

  validates :name, presence: true

  sig { returns(T.nilable(Integer)).override }
  attr_reader :id

  sig { returns(T.nilable(String)) }
  attr_reader :name

  sig { params(id: T.nilable(Integer), name: T.nilable(String)).void }
  def initialize(id, name)
    @id = id
    @name = name
  end

  sig { returns(T::Boolean) }
  def persisted?
    !!id
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def to_hash
    { id: id, name: name}
  end

  sig { returns(Integer) }
  def hash
    [id, name].hash
  end

  sig { params(other: T::untyped).returns(T::Boolean) }
  def ==(other)
    eql?(other)
  end

  sig { params(other: T::untyped).returns(T::Boolean) }
  def eql?(other)
    self.class == other.class &&
      self.id == other.id && self.name == other.name
  end
end
' > packages/teams/app/public/team.rb

echo '# typed: false
RSpec.describe Team, type: :model do
  describe "validity" do
    it "can be valid" do
      expect(Team.new(7, "test")).to be_valid
    end

    it "can be invalid" do
      expect(Team.new(7, nil)).not_to be_valid
    end
  end

  describe "#id" do
    it "does what you expect" do
      expect(Team.new(7, "test").id).to eq(7)
    end
  end

  describe "#name" do
    it "does what you expect" do
      expect(Team.new(7, "test").name).to eq("test")
    end
  end

  describe "#persisted?" do
    it "is true with an id" do
      expect(Team.new(7, "test").persisted?).to eq(true)
    end

    it "is false without an id" do
      expect(Team.new(nil, "test").persisted?).to eq(false)
    end
  end

  describe "comparisons" do
    it "should behave as expected" do
      expect(Team.new(1, "1")).to eq Team.new(1, "1")

      t = (1..2).map { |i| Team.new(i, "#{i}") }
      t2 = (1..2).map { |i| Team.new(i, "#{i}") }
      expect(t - t2).to eq([])

      t = (1..15).map { |i| Team.new(i, "#{i}") }
      t2 = (1..14).map { |i| Team.new(i, "#{i}") }
      expect(t - t2).to eq([Team.new(15, "15")])

      ## testing hash and eql? based comparisons
      t = (1..20).map { |i| Team.new(i, "#{i}") }
      t2 = (1..19).map { |i| Team.new(i, "#{i}") }
      expect(t - t2).to eq([Team.new(20, "20")])
    end 
  end
end
' > packages/teams/spec/public/team_spec.rb

echo '# typed: strict
class TeamRepository
  extend T::Sig

  sig { params(id: T.nilable(Integer)).returns(T.nilable(Team)) }
  def self.get(id)
    team_record = TeamRecord.find_by_id(id)
    Team.new(team_record.id, team_record.name) if team_record
  end

  sig { returns(T::Array[Team]) }
  def self.list
    TeamRecord.all.map { |t| Team.new(t.id, t.name) }
  end

  sig { params(team: Team).returns(Team) }
  def self.add(team)
    team_record = TeamRecord.create(team.to_hash)
    team = Team.new(team_record.id, team_record.name)
    team.instance_variable_set(:"@errors", team_record.errors)
    team
  end

  sig { params(team: Team).returns(T.any(FalseClass, Team)) }
  def self.edit(team)
    team_record = TeamRecord.find_by_id(team.id)
    return false unless team_record
    team_record.update(team.to_hash)
    team = Team.new(team_record.id, team_record.name)
    team.instance_variable_set(:"@errors", team_record.errors)
    team
  end

  sig { params(team: Team).void }
  def self.delete(team)
    TeamRecord.delete(team.id)
  end

  sig { returns(Integer) }
  def self.count
    TeamRecord.count
  end
end
' > packages/teams/app/public/team_repository.rb

echo '# typed: false
RSpec.describe TeamRepository do
  describe "#get" do
    it "returns a team when found" do
      team = create_team
      expect(TeamRepository.get(team.id)).to eq(Team.new(team.id, team.name))
    end

    it "returns nil when not found" do
      team = create_team
      expect(TeamRepository.get(team.id + 1)).to eq(nil)
    end
  end

  describe "#list" do
    it "returns all teams" do
      team1 = create_team
      team2 = create_team
      expect(TeamRepository.list).to eq([team1, team2])
    end
  end

  describe "#add and #count and #list" do
    it "adds a new team to the repository which is counted and listed" do
      expect(TeamRepository.count).to eq(0)
      expect(TeamRepository.list).to eq([])
      TeamRepository.add(Team.new(nil, "something"))
      expect(TeamRepository.count).to eq(1)
      actual_team = TeamRepository.list.first
      expect(actual_team.id).to_not be_nil
      expect(actual_team.name).to eq("something")
    end
  end

  describe "#edit" do
    it "changes a team in the repository when found" do
      team = create_team(name: "alpha")
      new_team = Team.new(team.id, "beta")
      expect(TeamRepository.edit(new_team)).to eq(new_team)
      expect(TeamRepository.list).to eq([new_team])
    end

    it "does not change a team in the repository when NOT found" do
      team = create_team(name: "alpha")
      expect(TeamRepository.list).to eq([team])
      new_team = Team.new(team.id + 1, "beta")
      expect(TeamRepository.edit(new_team)).to eq(false)
      expect(TeamRepository.list).to eq([team])
    end

    it "does not change a team in the repository when NOT valid" do
      team = create_team(name: "alpha")
      expect(TeamRepository.list).to eq([team])
      new_team = Team.new(team.id, nil)
      expect(TeamRepository.edit(new_team)).to eq(new_team)
      expect(TeamRepository.list).to eq([team])
    end
  end

  describe "#delete" do
    it "removes teams from the repository when found" do
      team1 = create_team
      team2 = create_team
      team3 = create_team
      expect(TeamRepository.list).to eq([team1, team2, team3])
      TeamRepository.delete(team2)
      expect(TeamRepository.list).to eq([team1, team3])
    end

    it "does not remove team from the repository when NOT found" do
      team = create_team
      expect(TeamRepository.list).to eq([team])
      TeamRepository.delete(Team.new(-1, ""))
      expect(TeamRepository.list).to eq([team])
    end
  end
end
' > packages/teams/spec/public/team_repository_spec.rb

echo '# typed: ignore
class TeamsController < ApplicationController
  before_action :set_team, only: %i[ show edit update destroy ]

  # GET /teams or /teams.json
  def index
    @teams = TeamRepository.list
  end

  # GET /teams/1 or /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new(nil, nil)
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams or /teams.json
  def create
    @team = TeamRepository.add(Team.new(nil, team_params[:name]))

    respond_to do |format|
      if @team.persisted?
        format.html { redirect_to team_url(@team), notice: "Team was successfully created." }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1 or /teams/1.json
  def update
    respond_to do |format|
      @team = TeamRepository.edit(Team.new(params[:id].to_i, team_params[:name]))
      if @team.errors.empty?
        format.html { redirect_to team_url(@team), notice: "Team was successfully updated." }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1 or /teams/1.json
  def destroy
    TeamRepository.delete(@team)

    respond_to do |format|
      format.html { redirect_to teams_url, notice: "Team was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = TeamRepository.get(params[:id].to_i)
    end

    # Only allow a list of trusted parameters through.
    def team_params
      params.require(:team).permit(:name)
    end
end
' > packages/teams_admin/app/controllers/teams_controller.rb

echo '# typed: false
class Game < ApplicationRecord
  include HistoricalPerformanceIndicator
  extend T::Sig

  validates :date, :location, :first_team, :second_team, :winning_team,
            :first_team_score, :second_team_score, presence: true
  belongs_to :first_team, class_name: "TeamRecord"
  belongs_to :second_team, class_name: "TeamRecord"
end
' > packages/games/app/models/game.rb

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
    defaults = {
      first_team_id: -> { create_team.id },
      second_team_id: -> { create_team.id },
      winning_team: 2,
      first_team_score: 2,
      second_team_score: 3,
      location: "Somewhere",
      date: Date.today
    }
    defaults.merge(overrides)
  end

  def new_game(overrides = {})
    Game.new { |game| apply(game, game_params(overrides), {}) }
  end

  def create_game(overrides = {})
    new_game(overrides).tap(&:save!)
  end

  private

  def counter
    @counter ||= 0
    @counter += 1
  end

  def apply(object, defaults, overrides)
    options = defaults.merge(overrides)
    options.each do |method, value_or_proc|
      object.__send__(
          "#{method}=",
          value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
    end
  end
end
' > spec/support/object_creation_methods.rb

echo '# typed: ignore
class PredictionsController < ApplicationController
  def new
    @teams = TeamRepository.list
  end

  def create
    predictor = Predictor.new
    predictor.learn(TeamRepository.list, Game.all)
    @prediction = predictor.predict(
        TeamRepository.get(params["first_team"]["id"].to_i),
        TeamRepository.get(params["second_team"]["id"].to_i))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(T.nilable(Integer)) }
  def id; end
end
' > packages/predictor_interface/app/public/contender.rb

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

RSpec.describe "/teams", type: :request do
  let(:team1) { create_team }
  let(:team2) { create_team }

  # Team. As you add validations to Team, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    team_params(name: "something")
  }

  let(:invalid_attributes) {
    team_params(name: nil)
  }

  describe "GET /index" do
    it "renders a successful response" do
      create_team valid_attributes
      get teams_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      team = create_team valid_attributes
      get team_url(team)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_team_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      team = create_team valid_attributes
      get edit_team_url(team)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Team" do
        expect {
          post teams_url, params: { team: valid_attributes }
        }.to change(TeamRepository, :count).by(1)
      end

      it "redirects to the created team" do
        post teams_url, params: { team: valid_attributes }
        expect(response).to redirect_to(team_url(TeamRepository.list.last.id))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Team" do
        expect {
          post teams_url, params: { team: invalid_attributes }
        }.to change(TeamRepository, :count).by(0)
      end

      it "renders a successful response (i.e. to display the new template)" do
        post teams_url, params: { team: invalid_attributes }
        expect(response).not_to be_successful
        expect(response.body).to include("Name can&#39;t be blank")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: "test" }
      }

      it "updates the requested team" do
        team = create_team valid_attributes
        patch team_url(team), params: { team: new_attributes }
        team = TeamRepository.get(team.id)
        expect(team.name).to eq("test")
      end

      it "redirects to the team" do
        team = create_team valid_attributes
        patch team_url(team), params: { team: new_attributes }
        team = TeamRepository.get(team.id)
        expect(response).to redirect_to(team_url(team))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the edit template)" do
        team = create_team valid_attributes
        patch team_url(team), params: { team: invalid_attributes }
        expect(response).to have_http_status(422)
        expect(response.body).to include("Name can&#39;t be blank")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested team" do
      team = create_team valid_attributes
      expect {
        delete team_url(team)
      }.to change(TeamRepository, :count).by(-1)
    end

    it "redirects to the teams list" do
      team = create_team valid_attributes
      delete team_url(team)
      expect(response).to redirect_to(teams_url)
    end
  end
end
' > packages/teams_admin/spec/requests/teams_spec.rb

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
        rating: ::Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)
      )
      memo
    end

    games.each do |game|
      first_team_rating = @teams_lookup[game.first_team.id].rating
      second_team_rating = @teams_lookup[game.second_team.id].rating
      game_result = game.winning_team == 1 ?
          [[first_team_rating], [second_team_rating]] :
          [[second_team_rating], [first_team_rating]]
        ::Saulabs::TrueSkill::FactorGraph.new(game_result, [1, 2]).update_skills
    end
  end

  sig {override.params(first_team: Contender, second_team: Contender).returns(Prediction)}
  def predict(first_team, second_team)
    team1 = T.must(T.must(@teams_lookup)[T.must(first_team.id)]).team
    team2 = T.must(T.must(@teams_lookup)[T.must(second_team.id)]).team
    winner = higher_mean_team(first_team, second_team) ? team1 : team2
    Prediction.new(team1, team2, winner)
  end

  private

  sig {params(first_team: Contender, second_team: Contender).returns(T::Boolean)}
  def higher_mean_team(first_team, second_team)
    T.must(T.must(@teams_lookup)[T.must(first_team.id)]).rating.mean >
        T.must(T.must(@teams_lookup)[T.must(second_team.id)]).rating.mean
  end

  class TeamLookup < T::Struct
    const :team, Contender
    const :rating, Saulabs::TrueSkill::Rating
  end
  private_constant :TeamLookup
end

' > packages/predictor/app/public/predictor.rb

echo 'class TeamRecord
  def self.find_by_id(id); end
end
' > packages/teams/app/models/team_record.rbi

sed -i '1 i\# typed: ignore' packages/teams_admin/spec/routing/teams_routing_spec.rb