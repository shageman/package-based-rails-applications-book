# typed: false
RSpec.describe "games/show", type: :view do
  let(:team1) { create_team }
  let(:team2) { create_team }

  before(:each) do
    @game = assign(:game, create_game(
      location: "Location",
      first_team_id: team1.id,
      second_team_id: team2.id,
      winning_team: 4,
      first_team_score: 5,
      second_team_score: 6,
      date: Date.current
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Location/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
