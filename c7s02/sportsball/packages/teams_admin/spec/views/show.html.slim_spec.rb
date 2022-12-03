RSpec.describe "teams/show", type: :view do
  before(:each) do
    @team = assign(:team, create_team(
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
