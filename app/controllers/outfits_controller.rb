class OutfitsController < ApplicationController
  def index
    @outfits = Outfit.all
  end

  def show
    @outfit = Outfit.find(params[:id])
  end

  def new
    @outfit = Outfit.new
  end

  def create
    @outfit = Outfit.new(outfit_params)
    @outfit.user = current_user

    if @outfit.save
      redirect_to outfit_path(@outfit), notice: "Outfit created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
  end

  def update
    @outfit = current_user.outfits.find(params[:id])

    if @outfit.update(outfit_params)
      redirect_to outfit_path(@outfit), notice: "Outfit updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def outfit_params
    params.require(:outfit).permit(:name, :description, :status, :jacket)
  end
end
