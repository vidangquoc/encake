class FriendShipsController < ApplicationController
  # GET /friend_ships
  # GET /friend_ships.json
  def index
    @friend_ships = FriendShip.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @friend_ships }
    end
  end

  # GET /friend_ships/1
  # GET /friend_ships/1.json
  def show
    @friend_ship = FriendShip.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @friend_ship }
    end
  end

  # GET /friend_ships/new
  # GET /friend_ships/new.json
  def new
    @friend_ship = FriendShip.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @friend_ship }
    end
  end

  # GET /friend_ships/1/edit
  def edit
    @friend_ship = FriendShip.find(params[:id])
  end

  # POST /friend_ships
  # POST /friend_ships.json
  def create
    @friend_ship = FriendShip.new(params[:friend_ship])

    respond_to do |format|
      if @friend_ship.save
        format.html { redirect_to @friend_ship, notice: 'Friend ship was successfully created.' }
        format.json { render json: @friend_ship, status: :created, location: @friend_ship }
      else
        format.html { render action: "new" }
        format.json { render json: @friend_ship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /friend_ships/1
  # PUT /friend_ships/1.json
  def update
    @friend_ship = FriendShip.find(params[:id])

    respond_to do |format|
      if @friend_ship.update_attributes(params[:friend_ship])
        format.html { redirect_to @friend_ship, notice: 'Friend ship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @friend_ship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /friend_ships/1
  # DELETE /friend_ships/1.json
  def destroy
    @friend_ship = FriendShip.find(params[:id])
    @friend_ship.destroy

    respond_to do |format|
      format.html { redirect_to friend_ships_url }
      format.json { head :no_content }
    end
  end
end
