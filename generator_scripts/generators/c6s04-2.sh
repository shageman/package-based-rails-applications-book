#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step hides the Game and Team ActiveReccord objects within their packages
# and exposes needed APIs 
#
###############################################################################

rm packages/teams/app/models/team.rb
rm packages/teams/spec/models/team_spec.rb

mkdir packages/teams/app/public
mkdir packages/teams/spec/public

echo 'enforce_dependencies: true
enforce_privacy: true
dependencies:
- packages/predictor_interface
- packages/rails_shims
' > packages/teams/package.yml

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

echo '# typed: true
class Team
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  include Contender
  extend T::Sig
  
  validates :name, presence: true

  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def persisted?
    !!id
  end

  def to_hash
    { id: id, name: name}
  end

  def ==(other)
    id == other.id && name == other.name
  end
end
' > packages/teams/app/public/team.rb

echo '# typed: false
RSpec.describe Team, type: :model do
  describe "validity" do
    it "can be valid" do
      expect(Team.new(7, "test")).to be_valid
    end

    it "is not valid with a nil name" do
      expect(Team.new(7, nil)).to_not be_valid
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

  describe "#to_hash" do
    it "hashes based on params" do
      expect(Team.new(7, "test").to_hash).to eq({id: 7, name: "test"})
    end
  end 

  describe "#==" do
    it "returns true for objects with the same attributes" do
      team1 = Team.new(1, "test")
      team2 = Team.new(1, "test")
      expect(team1 == team2).to eq(true)
    end

    it "returns false for objects with different attributes" do
      team1 = Team.new(5, "test")
      team2 = Team.new(1, "test")
      expect(team1 == team2).to eq(false)

      team1 = Team.new(1, "test")
      team2 = Team.new(1, "nothing")
      expect(team1 == team2).to eq(false)
    end
  end
end
' > packages/teams/spec/public/team_spec.rb

echo '# typed: false
class TeamRepository
  def self.get(id)
    team_record = TeamRecord.find_by_id(id)
    Team.new(team_record.id, team_record.name) if team_record
  end

  def self.list
    TeamRecord.all.map { |t| Team.new(t.id, t.name) }
  end

  def self.add(team)
    team_record = TeamRecord.create(team.to_hash)
    Team.new(team_record.id, team_record.name)
  end

  def self.edit(team)
    record = TeamRecord.find_by_id(team.id)
    return false unless record
    record.update(team.to_hash)
  end

  def self.delete(team)
    TeamRecord.delete(team.id)
  end

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
    it "adds a new team to the repository" do
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
      expect(TeamRepository.edit(new_team)).to eq(true)
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
      expect(TeamRepository.edit(new_team)).to eq(false)
      expect(TeamRepository.list).to eq([team])
    end
  end 

  describe "#delete" do
    it "removes teams from the repository when found" do
      team1 = create_team
      team2 = create_team
      team3 = create_team
      expect(TeamRepository.list).to eq([team1, team2, team3])
      expect(TeamRepository.delete(team2)).to eq(1)
      expect(TeamRepository.list).to eq([team1, team3]) 
    end

    it "removes teams from the repository when found" do
      team = create_team
      expect(TeamRepository.list).to eq([team])
      expect(TeamRepository.delete(Team.new(-1, ""))).to eq(0)
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
      if TeamRepository.edit(Team.new(params[:id], team_params[:name]))
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
      @team = TeamRepository.get(params[:id])
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
        TeamRepository.get(params["first_team"]["id"]),
        TeamRepository.get(params["second_team"]["id"]))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

sed -i 's/team.reload/team = TeamRepository.get(team.id)/g' packages/teams_admin/spec/requests/teams_spec.rb
sed -i 's/Team, :count/TeamRepository, :count/g' packages/teams_admin/spec/requests/teams_spec.rb
sed -i 's/Team.all.last/TeamRecord.all.last/g' packages/teams_admin/spec/requests/teams_spec.rb

bundle install --local

bin/rails sorbet:update:all

