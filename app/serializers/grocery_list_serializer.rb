class GroceryListSerializer
  def initialize(list)
    @list = list
  end

  def serializable_hash
    {
      id: @list.id,
      name: @list.name,
      source: @list.source,
      items: @list.grocery_items.map { |i| GroceryItemSerializer.new(i).serializable_hash },
      created_at: @list.created_at,
      updated_at: @list.updated_at
    }
  end
end
