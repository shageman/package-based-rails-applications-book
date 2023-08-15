# PredictionComponent

## Usage

```ruby
# To record that a game was played
PredictionComponent::Client::RecordGameCreation.(
        league_id: random_id,
        game_id: random_id,
        first_team_id: random_id,
        second_team_id: random_id,
        winning_team: 1 # 1: first team won, 2: second team won
      ) # all parameters are optional

# To get all the teams and their strengths that are in the league
PredictionComponent::Client::FetchLeague.(LEAGUE_ID)

# To get a team's in the league
PredictionComponent::Client::FetchLeague.(LEAGUE_ID, TEAM_ID)
```

## What's currently working

PredictionComponent...
* defaults ratings to 1500 mean and 1000 deviation
* increases rating mean of the first team after that team wins a game
* decreases rating mean of the first team after that team looses a game
* increases rating mean of the second team after that team wins a game
* decreases rating mean of the second team after that team looses a game
* increases rating mean for subsequent wins, but less and less so
* works for many teams
* protects against game recording duplication
* allows send theRecordGameCreation command via the client
* allows fetching a team (in a league) strength with and without version
* allows fetching a league with and without version

## Todo

* implement game deletions
* implement game updates

## Continuous Testing

```
cd prediction-component
fswatch -o lib spec | xargs -n1 -I{} bundle exec rspec
```