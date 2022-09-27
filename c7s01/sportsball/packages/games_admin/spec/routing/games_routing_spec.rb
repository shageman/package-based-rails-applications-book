# typed: false

RSpec.describe GamesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/games").to route_to("games#index")
    end

    it "routes to #new" do
      expect(get: "/games/new").to route_to("games#new")
    end

    it "routes to #show" do
      expect(get: "/games/1").to route_to("games#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/games/1/edit").to route_to("games#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/games").to route_to("games#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/games/1").to route_to("games#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/games/1").to route_to("games#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/games/1").to route_to("games#destroy", id: "1")
    end
  end
end
