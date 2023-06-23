# typed: false
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
      expect(TeamRepository.delete(team2)).to eq(1)
      expect(TeamRepository.list).to eq([team1, team3])
    end

    it "does not remove team from the repository when NOT found" do
      team = create_team
      expect(TeamRepository.list).to eq([team])
      expect(TeamRepository.delete(Team.new(-1, ""))).to eq(0)
      expect(TeamRepository.list).to eq([team])
    end
  end
end

