RSpec.describe "games/edit", type: :view do
  let(:team1) { create_team }
  let(:team2) { create_team }

  before(:each) do
    @game = assign(:game, create_game(
      location: "MyString",
      first_team_id: team1.id,
      second_team_id: team2.id,
      winning_team: 1,
      first_team_score: 1,
      second_team_score: 1,
      date: Date.current
    ))
  end

  it "renders the edit game form" do
    render

    assert_select "form[action=?][method=?]", game_path(@game), "post" do

      assert_select "input[name=?]", "game[location]"

      assert_select "input[name=?]", "game[first_team_id]"

      assert_select "input[name=?]", "game[second_team_id]"

      assert_select "input[name=?]", "game[winning_team]"

      assert_select "input[name=?]", "game[first_team_score]"

      assert_select "input[name=?]", "game[second_team_score]"
    end
  end
end
