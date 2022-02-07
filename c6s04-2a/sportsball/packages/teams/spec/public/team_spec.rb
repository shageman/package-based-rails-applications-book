# typed: false
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

