# typed: false
RSpec.describe ServiceLocator do
  subject { described_class.instance }

  describe "when it can be found" do
    it "getting a service raises an error" do
      expect { subject.get_service(:some_service) }.to raise_error(ServiceNotFoundError)
    end
  end

  describe "getting a given service" do
    it "returns that service instance" do
      subject.register_service(:some_set_service, :a)
      expect(subject.get_service(:some_set_service)).to eq(:a)
    end
  end
end

