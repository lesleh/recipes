require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "requires a name" do
    ingredient = Ingredient.new(recipe: recipes(:tomato_pasta), name: "")

    assert_not ingredient.valid?
  end

  test "requires a recipe" do
    assert_not Ingredient.new(name: "salt").valid?
  end

  test "renders quantity, unit and name" do
    assert_equal "1.6 kg whole chicken", ingredients(:chicken).to_s
  end

  test "skips blank parts when rendering" do
    assert_equal "1 lemon", ingredients(:lemon).to_s
  end

  test "assigns the next position within the recipe" do
    recipe = recipes(:roast_chicken)
    ingredient = recipe.ingredients.create!(name: "thyme")

    assert_equal 3, ingredient.position
  end

  test "keeps an explicitly given position" do
    ingredient = recipes(:roast_chicken).ingredients.create!(name: "thyme", position: 9)

    assert_equal 9, ingredient.position
  end
end
