# typed: strict
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

