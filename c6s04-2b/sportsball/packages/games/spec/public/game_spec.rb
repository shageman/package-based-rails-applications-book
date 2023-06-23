# typed: false
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

