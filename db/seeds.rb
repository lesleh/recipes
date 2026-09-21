# Sample recipes so a fresh checkout has something to look at.
# Safe to run repeatedly: recipes are matched on title.

SEED_RECIPES = [
  {
    title: "Lemon Garlic Roast Chicken",
    description: "A whole chicken roasted with lemon and garlic until the skin crisps.",
    servings: 4,
    prep_time_minutes: 20,
    cook_time_minutes: 90,
    instructions: <<~STEPS,
      Heat the oven to 200C.
      Halve the lemon and stuff it into the cavity with the garlic and thyme.
      Rub the skin with olive oil and season generously.
      Roast for 90 minutes, basting halfway through.
      Rest for 15 minutes before carving.
    STEPS
    ingredients: [
      { quantity: "1.6", unit: "kg", name: "whole chicken" },
      { quantity: "1", unit: "", name: "lemon" },
      { quantity: "6", unit: "cloves", name: "garlic" },
      { quantity: "4", unit: "sprigs", name: "thyme" },
      { quantity: "2", unit: "tbsp", name: "olive oil" }
    ]
  },
  {
    title: "Weeknight Tomato Pasta",
    description: "Twenty minutes, one pan, mostly cupboard ingredients.",
    servings: 2,
    prep_time_minutes: 5,
    cook_time_minutes: 15,
    instructions: <<~STEPS,
      Boil the pasta in well salted water.
      Soften the garlic in olive oil over a low heat.
      Add the tomatoes and chilli, simmer for 10 minutes.
      Toss the drained pasta through the sauce with the basil.
    STEPS
    ingredients: [
      { quantity: "200", unit: "g", name: "spaghetti" },
      { quantity: "400", unit: "g", name: "tinned tomatoes" },
      { quantity: "3", unit: "cloves", name: "garlic" },
      { quantity: "1", unit: "pinch", name: "chilli flakes" },
      { quantity: "1", unit: "handful", name: "basil" }
    ]
  },
  {
    title: "Overnight Oats",
    description: "Assemble at night, eat straight from the fridge.",
    servings: 1,
    prep_time_minutes: 5,
    instructions: <<~STEPS,
      Stir the oats, milk and yoghurt together in a jar.
      Add the honey and a pinch of salt.
      Refrigerate overnight and top with berries before eating.
    STEPS
    ingredients: [
      { quantity: "50", unit: "g", name: "rolled oats" },
      { quantity: "120", unit: "ml", name: "milk" },
      { quantity: "2", unit: "tbsp", name: "natural yoghurt" },
      { quantity: "1", unit: "tsp", name: "honey" },
      { quantity: "1", unit: "handful", name: "berries" }
    ]
  }
]

SEED_RECIPES.each do |attributes|
  ingredients = attributes.fetch(:ingredients)
  recipe = Recipe.find_or_initialize_by(title: attributes[:title])
  recipe.assign_attributes(attributes.except(:ingredients, :title))
  recipe.ingredients.destroy_all if recipe.persisted?
  ingredients.each_with_index do |ingredient, index|
    recipe.ingredients.build(ingredient.merge(position: index + 1))
  end
  recipe.save!
end

puts "Seeded #{Recipe.count} recipes."
