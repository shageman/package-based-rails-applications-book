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

