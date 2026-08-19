class Api::V1::GroceryItemsController < Api::V1::BaseController
  before_action :set_grocery_list
  before_action :set_grocery_item, only: [:update, :destroy]

  def create
    item = @grocery_list.grocery_items.build(grocery_item_params)
    if item.save
      render json: GroceryItemSerializer.new(item).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: item.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def update
    if @grocery_item.update(grocery_item_params)
      render json: GroceryItemSerializer.new(@grocery_item).serializable_hash
    else
      render json: { error: { code: 422, message: @grocery_item.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def destroy
    @grocery_item.destroy
    head :no_content
  end

  private

  def set_grocery_list
    @grocery_list = current_user.grocery_lists.find(params[:grocery_list_id])
  end

  def set_grocery_item
    @grocery_item = @grocery_list.grocery_items.find(params[:id])
  end

  def grocery_item_params
    params.require(:grocery_item).permit(:name, :quantity, :unit, :status, :source, :recipe_id)
  end
end
