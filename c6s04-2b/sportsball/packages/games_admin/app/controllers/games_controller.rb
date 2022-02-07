# typed: false
class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy ]

  # GET /games or /games.json
  def index
    @games = GameRepository.list
  end

  # GET /games/1 or /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new(nil, nil, nil, nil, nil, nil, nil, nil)
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games or /games.json
  def create
    @game = GameRepository.add(Game.new(
        nil,
        Team.new(game_params[:first_team_id], nil),
        Team.new(game_params[:second_team_id], nil),
        game_params[:winning_team],
        game_params[:first_team_score],
        game_params[:second_team_score],
        game_params[:location],
        game_params[:date]
      )
    )

    respond_to do |format|
      if @game.persisted?
        format.html { redirect_to game_url(@game), notice: "Game was successfully created." }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    respond_to do |format|
      @game.first_team = TeamRepository.get(game_params[:first_team_id]) if game_params.has_key?("first_team_id")
      @game.second_team = TeamRepository.get(game_params[:second_team_id]) if game_params.has_key?("second_team_id")
      @game.winning_team = game_params[:winning_team] if game_params.has_key?("winning_team")
      @game.first_team_score = game_params[:first_team_score] if game_params.has_key?("first_team_score")
      @game.second_team_score = game_params[:second_team_score] if game_params.has_key?("second_team_score")
      @game.location = game_params[:location] if game_params.has_key?("location")
      @game.date = game_params[:date] if game_params.has_key?("date")

      @game = GameRepository.edit(@game)
      if @game.errors.empty?
        format.html { redirect_to game_url(@game), notice: "Game was successfully updated." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    GameRepository.delete(@game)

    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = GameRepository.get(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_params
      params[:game].delete(:id) if params[:game].has_key?(:id)
      params[:game].delete(:first_team) if params[:game].has_key?(:first_team)
      params[:game].delete(:second_team) if params[:game].has_key?(:second_team)
      params.require(:game).permit(
        :date,
        :location,
        :first_team_id,
        :second_team_id,
        :winning_team,
        :first_team_score,
        :second_team_score
      )
    end
end

