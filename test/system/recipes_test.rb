require "application_system_test_case"

class RecipesTest < ApplicationSystemTestCase
  test "creating a recipe with several ingredients" do
    visit root_path
    click_on "New recipe"

    fill_in "Title", with: "Pancakes"
    fill_in "Method (one step per line)", with: "Whisk.\nFry."

    within all(".ingredient-fields").first do
      fill_in "Quantity", with: "100"
      fill_in "Unit", with: "g"
      fill_in "Ingredient", with: "plain flour"
    end

    click_on "Add ingredient"

    within all(".ingredient-fields").last do
      fill_in "Quantity", with: "2"
      fill_in "Ingredient", with: "eggs"
    end

    click_on "Create Recipe"

    assert_text "Recipe was successfully created."
    assert_text "100 g plain flour"
    assert_text "2 eggs"
    assert_text "Whisk."
  end

  test "removing an existing ingredient" do
    recipe = recipes(:roast_chicken)
    visit edit_recipe_path(recipe)

    within all(".ingredient-fields").last do
      click_on "Remove"
    end

    click_on "Update Recipe"

    assert_text "Recipe was successfully updated."
    assert_no_text "1 lemon"
  end

  test "searching by ingredient" do
    visit root_path
    fill_in "Search recipes", with: "spaghetti"
    click_on "Search"

    assert_text "Weeknight Tomato Pasta"
    assert_no_text "Lemon Garlic Roast Chicken"
  end
end
