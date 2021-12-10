
RSpec.describe "teams/index", type: :view do
  before(:each) do
    assign(:teams, [
      Team.create!(
        name: "Name"
      ),
      Team.create!(
        name: "Name"
      )
    ])
  end

  it "renders a list of teams" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
  end
end
