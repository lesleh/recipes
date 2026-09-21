require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "requires a title" do
    recipe = Recipe.new(title: "")

    assert_not recipe.valid?
    assert_includes recipe.errors[:title], "can't be blank"
  end

  test "rejects non-positive timings and servings" do
    recipe = Recipe.new(title: "Toast", servings: 0, prep_time_minutes: -1, cook_time_minutes: 0)

    assert_not recipe.valid?
    assert_predicate recipe.errors[:servings], :any?
    assert_predicate recipe.errors[:prep_time_minutes], :any?
    assert_predicate recipe.errors[:cook_time_minutes], :any?
  end

  test "allows blank timings and servings" do
    assert_predicate Recipe.new(title: "Toast"), :valid?
  end

  test "total time sums prep and cook" do
    assert_equal 110, recipes(:roast_chicken).total_time_minutes
  end

  test "total time tolerates a missing half" do
    assert_equal 10, Recipe.new(prep_time_minutes: 10).total_time_minutes
  end

  test "total time is nil when neither timing is set" do
    assert_nil Recipe.new.total_time_minutes
  end

  test "instruction steps drop blank lines" do
    recipe = Recipe.new(instructions: "Chop.\n\n  Fry.  \n")

    assert_equal [ "Chop.", "Fry." ], recipe.instruction_steps
  end

  test "destroying a recipe destroys its ingredients" do
    recipe = recipes(:roast_chicken)

    assert_difference -> { Ingredient.count }, -2 do
      recipe.destroy
    end
  end

  test "ingredients come back in position order" do
    assert_equal [ "whole chicken", "lemon" ], recipes(:roast_chicken).ingredients.map(&:name)
  end

  test "search matches the title" do
    assert_includes Recipe.search("roast"), recipes(:roast_chicken)
    assert_not_includes Recipe.search("roast"), recipes(:tomato_pasta)
  end

  test "search matches the description" do
    assert_includes Recipe.search("one pan"), recipes(:tomato_pasta)
  end

  test "search matches an ingredient name" do
    assert_includes Recipe.search("spaghetti"), recipes(:tomato_pasta)
  end

  test "search returns each recipe once when several ingredients match" do
    results = Recipe.search("e")

    assert_equal results.map(&:id).uniq.size, results.size
  end

  test "search with a blank term returns everything" do
    assert_equal Recipe.count, Recipe.search("  ").count
  end

  test "search escapes LIKE wildcards" do
    assert_empty Recipe.search("%")
  end

  test "nested ingredient attributes with a blank name are ignored" do
    recipe = Recipe.create!(
      title: "Boiled Egg",
      ingredients_attributes: [ { name: "egg" }, { name: "" } ]
    )

    assert_equal [ "egg" ], recipe.ingredients.map(&:name)
  end
end
