class Api::V1::GroceryListsController < Api::V1::BaseController
  before_action :set_grocery_list, only: [:show, :update, :destroy]

  def index
    lists = current_user.grocery_lists.includes(:grocery_items)
    render json: lists.map { |l| GroceryListSerializer.new(l).serializable_hash }
  end

  def show
    render json: GroceryListSerializer.new(@grocery_list).serializable_hash
  end

  def create
    list = current_user.grocery_lists.build(grocery_list_params)
    if list.save
      render json: GroceryListSerializer.new(list).serializable_hash, status: :created
    else
      render json: { error: { code: 422, message: list.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def update
    if @grocery_list.update(grocery_list_params)
      render json: GroceryListSerializer.new(@grocery_list).serializable_hash
    else
      render json: { error: { code: 422, message: @grocery_list.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  def destroy
    @grocery_list.destroy
    head :no_content
  end

  private

  def set_grocery_list
    @grocery_list = current_user.grocery_lists.find(params[:id])
  end

  def grocery_list_params
    params.require(:grocery_list).permit(:name, :source)
  end
end
