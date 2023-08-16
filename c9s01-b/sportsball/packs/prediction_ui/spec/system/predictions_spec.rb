RSpec.describe "the prediction process", type: :system do
 
  def startup_sleep
    puts "Sleeping to wait for startup of server. Results are non-deterministic."
    sleep 3
  end

  before(:context) do
    `echo "\n\n\n\n>>>>>>>>>> NEW TEST RUN <<<<<<<<<<"`
    `date +"%Y-%m-%d %T"`
    puts "*** Scrubbing message DB"
    puts `PGUSER=root bundle exec mdb-recreate-db`
    # puts "*** Messages Status Before Tests"
    # puts `PGUSER=postgres bundle exec mdb-print-messages`

    # puts `PGUSER=postgres STREAM_NAME=someStream-111 bundle exec mdb-write-test-message`
    
    puts `PGUSER=postgres bundle exec mdb-print-messages`
    puts "*** Starting ComponentHost"
    fork { exec("PGUSER=postgres ruby eventide-backend/prediction_component/lib/service.rb") }
    startup_sleep
  end

  after (:context) do
    `ps ax | grep "ruby eventide-backend/prediction_component/lib/service.rb" | awk '{print "kill -s TERM " $1}' | sh`
  end
  before :each do
    team1 = create_team name: "UofL"
    team2 = create_team name: "UK"

    create_game first_team_id: team1.id, second_team_id: team2.id, winning_team: 1
    create_game first_team_id: team2.id, second_team_id: team1.id, winning_team: 2
    create_game first_team_id: team2.id, second_team_id: team1.id, winning_team: 2
  end

  it "get a new prediction" do
    visit "/"

    click_link "Predictions"

    select "UofL", from: "First team"
    select "UK", from: "Second team"
    click_button "What is it going to be"

    expect(page).to have_content "the winner will be UofL"
  end
end
