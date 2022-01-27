# typed: false
RSpec.describe "teams/new", type: :view do
  before(:each) do
    assign(:team, new_team(
      name: "MyString"
    ))
  end

  it "renders new team form" do
    render

    assert_select "form[action=?][method=?]", teams_path, "post" do

      assert_select "input[name=?]", "team[name]"
    end
  end
end
