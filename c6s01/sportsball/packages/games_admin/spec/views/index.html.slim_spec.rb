# typed: false
RSpec.describe "games/index", type: :view do
  let(:team1) { create_team }
  let(:team2) { create_team }
  before(:each) do
    assign(:games, [
      create_game(
        location: "Location1",
        first_team_id: team1.id,
        second_team_id: team2.id,
        winning_team: 4,
        first_team_score: 5,
        second_team_score: 6,
        date: Date.current
      ),
      create_game(
        location: "Location2",
        first_team_id: team1.id,
        second_team_id: team2.id,
        winning_team: 4,
        first_team_score: 5,
        second_team_score: 6,
        date: Date.current
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", text: "Location1", count: 1
    assert_select "tr>td", text: "Location2", count: 1
  end
end
