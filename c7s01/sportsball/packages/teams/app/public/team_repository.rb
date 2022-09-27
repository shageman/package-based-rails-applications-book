# typed: false
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
    team = Team.new(team_record.id, team_record.name)
    team.instance_variable_set(:"@errors", team_record.errors)
    team
  end

  def self.edit(team)
    team_record = TeamRecord.find_by_id(team.id)
    return false unless team_record
    team_record.update(team.to_hash)
    team = Team.new(team_record.id, team_record.name)
    team.instance_variable_set(:"@errors", team_record.errors)
    team
  end

  def self.delete(team)
    TeamRecord.delete(team.id)
  end

  def self.count
    TeamRecord.count
  end
end

