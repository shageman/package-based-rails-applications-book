RSpec.describe "teams admin", type: :system do
  it "allows for the management of teams" do
    visit "/teams"

    click_link "New Team"

    fill_in "Name", with: "UofL"
    click_on "Create Team"

    click_link "Back"

    click_link "New Team"

    fill_in "Name", with: "UK"
    click_on "Create Team"

    click_link "Back"

    expect(page).to have_content "UofL"
    expect(page).to have_content "UK"
  end
end
