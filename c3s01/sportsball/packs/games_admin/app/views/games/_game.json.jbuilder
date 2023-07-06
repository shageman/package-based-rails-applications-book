json.extract! game, :id, :date, :location, :first_team_id, :second_team_id, :winning_team, :first_team_score, :second_team_score, :created_at, :updated_at
json.url game_url(game, format: :json)
