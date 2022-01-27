RSpec.describe "teams/edit", type: :view do
  before(:each) do
    @team = assign(:team, create_team(
      name: "MyString"
    ))
  end

  it "renders the edit team form" do
    render

    assert_select "form[action=?][method=?]", team_path(@team), "post" do

      assert_select "input[name=?]", "team[name]"
    end
  end
end
