
RSpec.describe "Predictor Slice" do
  before do
    @team1 = create_team name: "A"
    @team2 = create_team name: "B"

    @predictor = HanamiPredictor::Slice["operations.create_prediction"]
  end

  it "predicts teams that have won in the past to win in the future" do
    game = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1

    prediction = @predictor.(
      [@team1, @team2], 
      [game], 
      HanamiPredictor::Structs::Prediction.new(@team2, @team1, nil)
    )
    expect(prediction.value!.winner).to eq @team1

    prediction = @predictor.(
      [@team1, @team2], 
      [game], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!.winner).to eq @team1
  end

  it "changes predictions based on games learned" do
    game1 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1
    game2 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 2
    game3 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 2

    prediction = @predictor.(
      [@team1, @team2], 
      [game1, game2, game3], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team1
    expect(prediction.value!.second_team).to eq @team2
    expect(prediction.value!.winner).to eq @team2
  end

  it "behaves funny when teams are equally strong" do
    prediction = @predictor.(
      [@team1, @team2], 
      [], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team1
    expect(prediction.value!.second_team).to eq @team2
    expect(prediction.value!.winner).to eq @team2

    prediction = @predictor.(
      [@team1, @team2], 
      [], 
      HanamiPredictor::Structs::Prediction.new(@team2, @team1, nil)
    )

    expect(prediction).to be_a Dry::Monads::Result::Success
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team2
    expect(prediction.value!.second_team).to eq @team1
    expect(prediction.value!.winner).to eq @team1
  end

  it "can return failures " do
    game1 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1

    prediction = @predictor.(
      [@team1], 
      [game1], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team3, nil)
    )

    expect(prediction).to be_a Dry::Monads::Result::Failure
    expect(prediction.failure?).to be_truthy
    expect(prediction.failure).to eq "Building Strengths: Team 2 not found"
  end
end

