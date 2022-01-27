# typed: false
RSpec.describe "teams/index", type: :view do
  before(:each) do
    assign(:teams, [
      create_team(
        name: "Name"
      ),
      create_team(
        name: "Name"
      )
    ])
  end

  it "renders a list of teams" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
  end
end
