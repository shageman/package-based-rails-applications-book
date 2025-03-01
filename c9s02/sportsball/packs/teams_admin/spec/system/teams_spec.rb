RSpec.describe "teams admin", type: :system do
  it "allows for the management of teams" do
    visit "/teams"

    click_link "New Team"

    expect(page).to have_selector("h1", text: "New team")
    fill_in "Name", with: "UofL"
    click_on "Create Team"

    click_link "Back"

    click_link "New Team"

    expect(page).to have_selector("h1", text: "New team")
    fill_in "Name", with: "UK"
    click_on "Create Team"

    click_link "Back to teams"
    
    expect(page).to have_content "UofL"
    expect(page).to have_content "UK"
  end
end
