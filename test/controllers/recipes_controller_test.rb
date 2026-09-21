require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:roast_chicken)
  end

  test "index lists recipes" do
    get recipes_path

    assert_response :success
    assert_select "h2", text: @recipe.title
  end

  test "index filters by the search term" do
    get recipes_path, params: { q: "spaghetti" }

    assert_response :success
    assert_select "h2", text: recipes(:tomato_pasta).title
    assert_select "h2", text: @recipe.title, count: 0
  end

  test "index reports when nothing matches" do
    get recipes_path, params: { q: "nothing here" }

    assert_response :success
    assert_select ".empty"
  end

  test "root routes to the index" do
    get root_path

    assert_response :success
  end

  test "show renders the recipe" do
    get recipe_path(@recipe)

    assert_response :success
    assert_select "h1", text: @recipe.title
    assert_select ".ingredients li", text: "1.6 kg whole chicken"
  end

  test "new renders a form with one blank ingredient row" do
    get new_recipe_path

    assert_response :success
    assert_select "[data-nested-form-target='list'] .ingredient-fields", 1
  end

  test "new renders a template row for adding ingredients" do
    get new_recipe_path

    assert_response :success
    assert_select "template[data-nested-form-target='template'] input[name*='NEW_RECORD']"
  end

  test "edit nests each ingredient id inside its own row" do
    get edit_recipe_path(@recipe)

    assert_response :success
    assert_select ".ingredient-fields input[name=?][type=hidden]",
                  "recipe[ingredients_attributes][0][id]"
  end

  test "create saves a recipe with ingredients" do
    assert_difference [ "Recipe.count", "Ingredient.count" ], 1 do
      post recipes_path, params: {
        recipe: {
          title: "Boiled Egg",
          instructions: "Boil for six minutes.",
          ingredients_attributes: { "0" => { name: "egg", quantity: "1" } }
        }
      }
    end

    assert_redirected_to recipe_path(Recipe.find_by(title: "Boiled Egg"))
  end

  test "create redisplays the form when invalid" do
    assert_no_difference "Recipe.count" do
      post recipes_path, params: { recipe: { title: "" } }
    end

    assert_response :unprocessable_entity
    assert_select ".errors"
  end

  test "the flash renders on the page a redirect lands on" do
    patch recipe_path(@recipe), params: { recipe: { title: "Roast Chicken" } }
    follow_redirect!

    assert_response :success
    assert_select ".flash", text: "Recipe was successfully updated."
  end

  test "update changes the recipe" do
    patch recipe_path(@recipe), params: { recipe: { title: "Roast Chicken" } }

    assert_redirected_to recipe_path(@recipe)
    assert_equal "Roast Chicken", @recipe.reload.title
  end

  test "update removes an ingredient flagged for destruction" do
    ingredient = ingredients(:lemon)

    assert_difference "Ingredient.count", -1 do
      patch recipe_path(@recipe), params: {
        recipe: {
          ingredients_attributes: { "0" => { id: ingredient.id, name: ingredient.name, _destroy: "1" } }
        }
      }
    end
  end

  test "update redisplays the form when invalid" do
    patch recipe_path(@recipe), params: { recipe: { title: "" } }

    assert_response :unprocessable_entity
    assert_select ".errors"
  end

  test "create attaches an uploaded photo" do
    post recipes_path, params: {
      recipe: { title: "Boiled Egg", image: fixture_file_upload("recipe.jpg", "image/jpeg") }
    }

    assert_predicate Recipe.find_by(title: "Boiled Egg").image, :attached?
  end

  test "create rejects an upload that is not an image" do
    assert_no_difference "Recipe.count" do
      post recipes_path, params: {
        recipe: { title: "Boiled Egg", image: fixture_file_upload("notes.txt", "text/plain") }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".errors", text: /JPEG, PNG or WebP/
  end

  test "update replaces an existing photo" do
    @recipe.image.attach(fixture_file_upload("recipe.jpg", "image/jpeg"))
    original_blob_id = @recipe.image.blob.id

    patch recipe_path(@recipe), params: {
      recipe: { image: fixture_file_upload("recipe.jpg", "image/jpeg") }
    }

    assert_predicate @recipe.reload.image, :attached?
    assert_not_equal original_blob_id, @recipe.image.blob.id
  end

  test "update removes the photo when the remove box is ticked" do
    @recipe.image.attach(fixture_file_upload("recipe.jpg", "image/jpeg"))

    perform_enqueued_jobs do
      patch recipe_path(@recipe), params: { recipe: { remove_image: "1" } }
    end

    assert_not_predicate @recipe.reload.image, :attached?
  end

  test "a new upload wins over a ticked remove box" do
    @recipe.image.attach(fixture_file_upload("recipe.jpg", "image/jpeg"))

    perform_enqueued_jobs do
      patch recipe_path(@recipe), params: {
        recipe: { remove_image: "1", image: fixture_file_upload("recipe.jpg", "image/jpeg") }
      }
    end

    assert_predicate @recipe.reload.image, :attached?
  end

  test "show renders the photo when one is attached" do
    @recipe.image.attach(fixture_file_upload("recipe.jpg", "image/jpeg"))

    get recipe_path(@recipe)

    assert_response :success
    assert_select "img.recipe__image"
  end

  test "index renders a thumbnail when a photo is attached" do
    @recipe.image.attach(fixture_file_upload("recipe.jpg", "image/jpeg"))

    get recipes_path

    assert_response :success
    assert_select ".recipe-card__thumbnail img"
  end

  test "the form posts as multipart so uploads arrive" do
    get new_recipe_path

    assert_response :success
    assert_select "form[enctype='multipart/form-data']"
  end

  test "destroy deletes the recipe" do
    assert_difference "Recipe.count", -1 do
      delete recipe_path(@recipe)
    end

    assert_redirected_to recipes_path
  end
end
