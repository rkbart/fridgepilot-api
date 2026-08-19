class Api::V1::PantryItemsController < Api::V1::BaseController
  before_action :set_pantry_item, only: [:show, :update, :destroy]

  def index
    items = current_user.pantry_items
    render json: items.map { |i| PantryItemSerializer.new(i).serializable_hash }
  end

  def show
    render json: PantryItemSerializer.new(@pantry_item).serializable_hash
  end

  def create
    item = current_user.pantry_items.build(pantry_item_params)
    if item.save
      render json: PantryItemSerializer.new(item).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: item.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def update
    if @pantry_item.update(pantry_item_params)
      render json: PantryItemSerializer.new(@pantry_item).serializable_hash
    else
      render json: { error: { code: 422, message: @pantry_item.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def destroy
    @pantry_item.destroy
    head :no_content
  end

  private

  def set_pantry_item
    @pantry_item = current_user.pantry_items.find(params[:id])
  end

  def pantry_item_params
    params.require(:pantry_item).permit(:name, :quantity, :unit, :category)
  end
end
