# typed: false
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

