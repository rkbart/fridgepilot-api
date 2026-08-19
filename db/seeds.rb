# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Sample recipes to exercise search and pagination in development and test.
unless Rails.env.production?
  user = User.first || User.create!(
    email: "demo@fridgepilot.dev",
    password: "password123",
    password_confirmation: "password123"
  )

  sample_recipes = [
    {
      name: "Alfredo Pasta",
      ingredients: [
        { name: "Fettuccine", quantity: 200, unit: "g" },
        { name: "Cream", quantity: 200, unit: "ml" },
        { name: "Parmesan", quantity: 50, unit: "g" }
      ],
      instructions: [
        "Boil the pasta until al dente.",
        "Melt the cream and cheese together.",
        "Toss the pasta in the sauce."
      ]
    },
    {
      name: "Beef Stroganoff",
      ingredients: [
        { name: "Beef", quantity: 400, unit: "g" },
        { name: "Mushrooms", quantity: 200, unit: "g" },
        { name: "Sour cream", quantity: 150, unit: "ml" }
      ],
      instructions: [
        "Brown the beef and mushrooms.",
        "Stir in the sour cream and simmer.",
        "Serve over pasta or rice."
      ]
    },
    {
      name: "Caesar Salad",
      ingredients: [
        { name: "Romaine", quantity: 1, unit: "head" },
        { name: "Croutons", quantity: 1, unit: "cup" },
        { name: "Caesar dressing", quantity: 3, unit: "tbsp" }
      ],
      instructions: [
        "Tear the lettuce into a bowl.",
        "Add croutons and dressing.",
        "Toss and serve."
      ]
    },
    {
      name: "Chicken Curry",
      ingredients: [
        { name: "Chicken", quantity: 500, unit: "g" },
        { name: "Coconut milk", quantity: 400, unit: "ml" },
        { name: "Curry paste", quantity: 2, unit: "tbsp" }
      ],
      instructions: [
        "Brown the chicken pieces.",
        "Add the curry paste and cook briefly.",
        "Pour in the coconut milk and simmer until thick."
      ]
    },
    {
      name: "Garlic Bread",
      ingredients: [
        { name: "Baguette", quantity: 1, unit: "pcs" },
        { name: "Butter", quantity: 50, unit: "g" },
        { name: "Garlic", quantity: 2, unit: "cloves" }
      ],
      instructions: [
        "Mix softened butter with crushed garlic.",
        "Spread over sliced baguette.",
        "Bake until golden."
      ]
    },
    {
      name: "Grilled Cheese",
      ingredients: [
        { name: "Bread", quantity: 2, unit: "slices" },
        { name: "Cheddar", quantity: 50, unit: "g" },
        { name: "Butter", quantity: 10, unit: "g" }
      ],
      instructions: [
        "Butter the bread slices.",
        "Fill with cheese and press together.",
        "Toast in a pan until golden on both sides."
      ]
    },
    {
      name: "Lemon Rice",
      ingredients: [
        { name: "Rice", quantity: 200, unit: "g" },
        { name: "Lemon", quantity: 1, unit: "pcs" },
        { name: "Butter", quantity: 20, unit: "g" }
      ],
      instructions: [
        "Cook the rice.",
        "Fold in lemon zest, juice, and butter.",
        "Fluff and serve warm."
      ]
    },
    {
      name: "Mashed Potatoes",
      ingredients: [
        { name: "Potatoes", quantity: 500, unit: "g" },
        { name: "Butter", quantity: 50, unit: "g" },
        { name: "Milk", quantity: 100, unit: "ml" }
      ],
      instructions: [
        "Boil the potatoes until soft.",
        "Mash with butter and milk.",
        "Season to taste."
      ]
    },
    {
      name: "Mushroom Risotto",
      ingredients: [
        { name: "Arborio rice", quantity: 200, unit: "g" },
        { name: "Mushrooms", quantity: 200, unit: "g" },
        { name: "Stock", quantity: 500, unit: "ml" }
      ],
      instructions: [
        "Soften the mushrooms.",
        "Add the rice and toast briefly.",
        "Add stock a ladle at a time until creamy."
      ]
    },
    {
      name: "Omelette",
      ingredients: [
        { name: "Eggs", quantity: 3, unit: "pcs" },
        { name: "Cheese", quantity: 30, unit: "g" },
        { name: "Butter", quantity: 10, unit: "g" }
      ],
      instructions: [
        "Beat the eggs and season.",
        "Cook in butter over medium heat.",
        "Fold in the cheese and serve."
      ]
    },
    {
      name: "Pancakes",
      ingredients: [
        { name: "Flour", quantity: 150, unit: "g" },
        { name: "Milk", quantity: 200, unit: "ml" },
        { name: "Egg", quantity: 1, unit: "pcs" }
      ],
      instructions: [
        "Whisk the batter until smooth.",
        "Cook spoonfuls in a hot pan.",
        "Flip when bubbles form."
      ]
    },
    {
      name: "Pesto Pasta",
      ingredients: [
        { name: "Pasta", quantity: 200, unit: "g" },
        { name: "Pesto", quantity: 3, unit: "tbsp" },
        { name: "Pine nuts", quantity: 20, unit: "g" }
      ],
      instructions: [
        "Cook the pasta and reserve some water.",
        "Toss with pesto, loosening with pasta water.",
        "Top with pine nuts."
      ]
    },
    {
      name: "Quiche",
      ingredients: [
        { name: "Pie crust", quantity: 1, unit: "pcs" },
        { name: "Eggs", quantity: 4, unit: "pcs" },
        { name: "Cream", quantity: 200, unit: "ml" }
      ],
      instructions: [
        "Blind bake the crust.",
        "Whisk eggs with cream and season.",
        "Pour into crust and bake until set."
      ]
    },
    {
      name: "Roast Chicken",
      ingredients: [
        { name: "Chicken", quantity: 1.2, unit: "kg" },
        { name: "Butter", quantity: 30, unit: "g" },
        { name: "Herbs", quantity: 1, unit: "bunch" }
      ],
      instructions: [
        "Rub the chicken with butter and herbs.",
        "Roast until golden and cooked through.",
        "Rest before carving."
      ]
    },
    {
      name: "Spaghetti Bolognese",
      ingredients: [
        { name: "Spaghetti", quantity: 200, unit: "g" },
        { name: "Minced beef", quantity: 300, unit: "g" },
        { name: "Tomato sauce", quantity: 400, unit: "ml" }
      ],
      instructions: [
        "Brown the minced beef.",
        "Add the tomato sauce and simmer.",
        "Serve over cooked spaghetti."
      ]
    },
    {
      name: "Tomato Soup",
      ingredients: [
        { name: "Tomatoes", quantity: 500, unit: "g" },
        { name: "Onion", quantity: 1, unit: "pcs" },
        { name: "Stock", quantity: 300, unit: "ml" }
      ],
      instructions: [
        "Soften the onion.",
        "Add tomatoes and stock, then simmer.",
        "Blend until smooth and season."
      ]
    },
    {
      name: "Vegetable Stir Fry",
      ingredients: [
        { name: "Broccoli", quantity: 200, unit: "g" },
        { name: "Bell pepper", quantity: 1, unit: "pcs" },
        { name: "Soy sauce", quantity: 2, unit: "tbsp" }
      ],
      instructions: [
        "Heat a wok over high heat.",
        "Stir fry the vegetables until crisp.",
        "Add soy sauce and toss."
      ]
    }
  ]

  sample_recipes.each do |attrs|
    user.recipes.find_or_create_by!(name: attrs[:name]) do |recipe|
      recipe.ingredients = attrs[:ingredients].map(&:stringify_keys)
      recipe.instructions = attrs[:instructions]
    end
  end

  puts "Seeded #{user.recipes.count} recipes for #{user.email}"
end
