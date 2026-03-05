class OutfitsController < ApplicationController
  def index
    @outfits = Outfit.all
  end

  def show
    @outfit = Outfit.find(params[:id])
  end

  def new
    @outfit = if params[:outfit_id].present?
    current_user.outfits.find(params[:outfit_id])
    else
      Outfit.new
    end
  end

  def create
    @outfit = Outfit.new(outfit_params)
    @outfit.user = current_user

    if @outfit.save
      if params[:open_in_new].present?
        redirect_to new_outfit_path(outfit_id: @outfit.id), notice: "Outfit draft created!"
      else
        redirect_to outfit_path(@outfit), notice: "Outfit created!"
      end
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

  def chat
    @outfit = Outfit.find(params[:id])
    @messages = @outfit.messages
    @message = Message.new
  end

  private

  def outfit_params
  params.require(:outfit).permit(:name, :description, :status, :jacket)
end

  end
