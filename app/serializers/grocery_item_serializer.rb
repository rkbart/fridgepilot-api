class GroceryItemSerializer
  def initialize(item)
    @item = item
  end

  def serializable_hash
    {
      id: @item.id,
      name: @item.name,
      quantity: @item.quantity,
      unit: @item.unit,
      status: @item.status,
      source: @item.source,
      recipe_id: @item.recipe_id,
      created_at: @item.created_at,
      updated_at: @item.updated_at
    }
  end
end
