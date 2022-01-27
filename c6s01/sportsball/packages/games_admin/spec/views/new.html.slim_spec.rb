# typed: false

RSpec.describe "games/new", type: :view do
  before(:each) do
    assign(:game, Game.new(
      location: "MyString",
      first_team_id: 1,
      second_team_id: 1,
      winning_team: 1,
      first_team_score: 1,
      second_team_score: 1
    ))
  end

  it "renders new game form" do
    render

    assert_select "form[action=?][method=?]", games_path, "post" do

      assert_select "input[name=?]", "game[location]"

      assert_select "input[name=?]", "game[first_team_id]"

      assert_select "input[name=?]", "game[second_team_id]"

      assert_select "input[name=?]", "game[winning_team]"

      assert_select "input[name=?]", "game[first_team_score]"

      assert_select "input[name=?]", "game[second_team_score]"
    end
  end
end
