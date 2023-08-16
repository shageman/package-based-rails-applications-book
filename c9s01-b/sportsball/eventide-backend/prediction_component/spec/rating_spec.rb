RSpec.describe "The system" do
  def random_id
    rand(1_000_000_000)
  end

  let!(:store) { PredictionComponent::Store.build }

  def startup_sleep
    puts "Sleeping to wait for startup of server. Results are non-deterministic."
    sleep 3
  end

  def process_sleep
    puts "Sleeping to wait for processing of messages. Results are non-deterministic."
    sleep 3
  end

  def read_version_from_store(id, version:, max_tries: 50)
    tries = 0
    while true do
      tries += 1
      stored_value, actual_version = PredictionComponent::Client::FetchTeamStrength.(id, include: :version)

      if version == actual_version
        break 
      elsif tries >= max_tries
        raise "Didn't read expected version. Expected: #{version}. Got: #{actual_version}"
      else
        sleep 0.05
      end
    end
    stored_value
  end

  before(:context) do
    `echo "\n\n\n\n>>>>>>>>>> NEW TEST RUN <<<<<<<<<<"`
    `date +"%Y-%m-%d %T"`
    puts "*** Scrubbing message DB"
    puts `PGUSER=postgres bundle exec mdb-create-db`
    puts "*** Messages Status Before Tests"
    puts `PGUSER=postgres bundle exec mdb-print-messages`

    puts `PGUSER=postgres STREAM_NAME=someStream-111 bundle exec mdb-write-test-message`
    
    puts `PGUSER=postgres bundle exec mdb-print-messages`
    puts "*** Starting ComponentHost"
    fork { exec("PGUSER=postgres ruby lib/service.rb") }
    startup_sleep
  end

  after (:context) do
      `ps ax | grep "ruby lib/service" | awk '{print "kill -s TERM " $1}' | sh`
  end

  describe "PredictionComponent" do
    it "defaults ratings to 1500 and 1000" do
      team_id = random_id

      team_strength = read_version_from_store(team_id, version: :no_stream)

      expect(team_strength.mean).to eq 1500
      expect(team_strength.deviation).to eq 1000
    end

    describe "effects of winning and loosing" do
      it "increases ratings of the first team after that team wins a game" do
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(first_team_id: team_id)
        team_strength = read_version_from_store(team_id, version: 0)

        expect(team_strength.mean).to be_between(1501, 2500).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
      end

      it "decreases ratings of the first team after that team looses a game" do
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(first_team_id: team_id, winning_team: 2)
        team_strength = read_version_from_store(team_id, version: 0)

        expect(team_strength.mean).to be_between(0, 1499).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
      end

      it "increases ratings of the second team after that team wins a game" do
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(second_team_id: team_id, winning_team: 2)
        team_strength = read_version_from_store(team_id, version: 0)

        expect(team_strength.mean).to be_between(1501, 2500).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
      end

      it "decreases ratings of the second team after that team looses a game" do
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(second_team_id: team_id)
        team_strength = read_version_from_store(team_id, version: 0)

        expect(team_strength.mean).to be_between(0, 1499).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
      end

      it "increases mean for subsequent wins, but less and less so" do
        first_team_id = random_id
        second_team_id = random_id

        team_strength = read_version_from_store(first_team_id, version: :no_stream)
        mean_0 = team_strength.mean

        PredictionComponent::Client::RecordGameCreation.(first_team_id: first_team_id, second_team_id: second_team_id)

        team_strength = read_version_from_store(first_team_id, version: 0)
        mean_1 = team_strength.mean

        PredictionComponent::Client::RecordGameCreation.(first_team_id: first_team_id, second_team_id: second_team_id)

        team_strength = read_version_from_store(first_team_id, version: 1)
        mean_2 = team_strength.mean

        PredictionComponent::Client::RecordGameCreation.(first_team_id: first_team_id, second_team_id: second_team_id)

        team_strength = read_version_from_store(first_team_id, version: 2)
        mean_3 = team_strength.mean

        expect(mean_0 < mean_1).to be_truthy
        expect(mean_1 < mean_2).to be_truthy
        expect(mean_2 < mean_3).to be_truthy

        expect([mean_0 - mean_1, mean_1 - mean_2, mean_2 - mean_3]).to eq [mean_0 - mean_1, mean_1 - mean_2, mean_2 - mean_3].sort
      end

      it "works for many teams" do
        first_team_id = random_id
        second_team_id = random_id
        third_team_id = random_id
        fourth_team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(first_team_id: first_team_id, second_team_id: second_team_id, winning_team: 2)
        #without the next line, the spec doesn't pass
        second_team_strength_0 = read_version_from_store(second_team_id, version: 0)
        PredictionComponent::Client::RecordGameCreation.(first_team_id: second_team_id, second_team_id: third_team_id, winning_team: 2)
        #without the next line, the spec doesn't pass
        third_team_strength_0 = read_version_from_store(third_team_id, version: 0)
        PredictionComponent::Client::RecordGameCreation.(first_team_id: third_team_id, second_team_id: fourth_team_id, winning_team: 2)

        first_team_strength = read_version_from_store(first_team_id, version: 0)
        second_team_strength = read_version_from_store(second_team_id, version: 1)
        third_team_strength = read_version_from_store(third_team_id, version: 1)
        fourth_team_strength = read_version_from_store(fourth_team_id, version: 0)

        expect(first_team_strength.mean < second_team_strength.mean).to be_truthy
        expect(second_team_strength.mean < third_team_strength.mean).to be_truthy
        expect(third_team_strength.mean < fourth_team_strength.mean).to be_truthy
      end

      it "protects against command duplication" do
        game_id = random_id
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(first_team_id: team_id, game_id: game_id)
        PredictionComponent::Client::RecordGameCreation.(first_team_id: team_id, game_id: game_id)

        process_sleep
        _, version = PredictionComponent::Client::FetchTeamStrength.(team_id, include: :version)

        expect(version).to eq 0
      end

      it "allows send the RecordGameCreation command via the client" do
        expect { PredictionComponent::Client::RecordGameCreation.() }.to_not raise_exception
      end

      it "allows fetching a team strength with and without version" do
        team_id = random_id

        PredictionComponent::Client::RecordGameCreation.(first_team_id: team_id)
        read_version_from_store(team_id, version: 0)

        team_strength, version = PredictionComponent::Client::FetchTeamStrength.(team_id, include: :version)

        expect(team_strength.mean).to be_between(1501, 2500).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
        expect(version).to eq(0)

        team_strength = PredictionComponent::Client::FetchTeamStrength.(team_id)

        expect(team_strength.mean).to be_between(1501, 2500).inclusive
        expect(team_strength.deviation).to be_between(0, 999).inclusive
      end
    end
  end
end