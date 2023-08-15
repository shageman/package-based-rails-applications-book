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

sed -i 's/class_name: "Team"/class_name: "TeamRecord"/g' packs/games/app/public/game.rb

mv packs/teams/app/public/team.rb packs/teams/app/models/team_record.rb
sed -i 's/Team/TeamRecord/g' packs/teams/app/models/team_record.rb
sed -i '/TeamRecord/a\    self.table_name = "teams"' packs/teams/app/models/team_record.rb
cat packs/teams/app/models/team_record.rb

mv packs/teams/spec/public/team_spec.rb packs/teams/spec/models/team_record_spec.rb
sed -i 's/Team/TeamRecord/g' packs/teams/spec/models/team_record_spec.rb

echo 'class TeamRecord
  def self.find_by_id(id); end
end
' > packs/teams/app/models/team_record.rbi

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
' > packs/teams/app/public/team.rb

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
' > packs/teams/spec/public/team_spec.rb

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
' > packs/teams/app/public/team_repository.rb

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
' > packs/teams/spec/public/team_repository_spec.rb

echo 'inherit_from: ../../.rubocop.yml

Packs/ClassMethodsAsPublicApis:
  Enabled: false

Packs/RootNamespaceIsPackName:
  Enabled: false

Packs/TypedPublicApis:
  Enabled: false

Packs/DocumentedPublicApis:
  Enabled: false' > packs/teams/.rubocop.yml

sed -i 's/Team.all/TeamRepository.list/g' packs/prediction_ui/app/controllers/predictions_controller.rb
sed -i 's/Team.find/TeamRepository.get/g' packs/prediction_ui/app/controllers/predictions_controller.rb
sed -i 's/\["id"\]/["id"].to_i/g' packs/prediction_ui/app/controllers/predictions_controller.rb

sed -i 's/\[first_team.id\]/[T.must(first_team.id)]/g' packs/predictor/app/public/predictor/predictor.rb
sed -i 's/\[second_team.id\]/[T.must(second_team.id)]/g' packs/predictor/app/public/predictor/predictor.rb

#TODO: what is the reason we need this?
sed -i '/sig/c\  sig { abstract.returns(T.nilable(Integer)) }' packs/predictor_interface/app/public/contender.rb

sed -i 's/@teams = Team.all/@teams = TeamRepository.list/g' packs/teams_admin/app/controllers/teams_controller.rb
sed -i 's/@team = Team.new(team_params)/@team = TeamRepository.add(Team.new(nil, team_params[:name]))/g' packs/teams_admin/app/controllers/teams_controller.rb
sed -i 's/@team = Team.new/@team = Team.new(nil, nil)/g' packs/teams_admin/app/controllers/teams_controller.rb
sed -i 's/if @team.save/if @team.persisted?/g' packs/teams_admin/app/controllers/teams_controller.rb
sed -i '/if @team.update(team_params)/c\      @team = TeamRepository.edit(Team.new(params[:id].to_i, team_params[:name]))\
      if @team.errors.empty?' packs/teams_admin/app/controllers/teams_controller.rb
sed -i 's/@team.destroy/TeamRepository.delete(@team)/g' packs/teams_admin/app/controllers/teams_controller.rb
sed -i 's/@team = Team.find(params\[:id\])/@team = TeamRepository.get(params[:id].to_i)/g' packs/teams_admin/app/controllers/teams_controller.rb
cat packs/teams_admin/app/controllers/teams_controller.rb

sed -i "1i # typed: false" packs/teams_admin/spec/requests/teams_spec.rb
sed -i 's/to change(Team, :count)/to change(TeamRepository, :count)/g' packs/teams_admin/spec/requests/teams_spec.rb
sed -i 's/redirect_to(team_url(Team.all.last))/redirect_to(team_url(TeamRepository.list.last.id))/g' packs/teams_admin/spec/requests/teams_spec.rb
sed -i '/expect(response).not_to be_successful/a\        expect(response.body).to include("Name can&#39;t be blank")' packs/teams_admin/spec/requests/teams_spec.rb
sed -i 's/team.reload/team = TeamRepository.get(team.id)/g' packs/teams_admin/spec/requests/teams_spec.rb
cat packs/teams_admin/spec/requests/teams_spec.rb

sed -i "1i # typed: ignore" packs/teams_admin/spec/routing/teams_routing_spec.rb

sed -i "1i # typed: true" spec/support/object_creation_methods.rb
sed -i '/defaults = /a\      id: nil,' spec/support/object_creation_methods.rb
sed -i '/Team.new/c\    a = team_params(overrides)\
    Team.new(a[:id], a[:name])' spec/support/object_creation_methods.rb
sed -i '/new_team(overrides).tap(&:save!)/c\    team = TeamRepository.add(new_team(overrides))\
    Kernel.raise "Team creation failed" unless team.persisted?\
    team' spec/support/object_creation_methods.rb
cat spec/support/object_creation_methods.rb
