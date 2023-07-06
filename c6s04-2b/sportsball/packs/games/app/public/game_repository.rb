# typed: false
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

