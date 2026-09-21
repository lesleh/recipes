class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  def index
    @query = params[:q]
    @recipes = Recipe.search(@query).by_title.with_attached_image
  end

  def show
  end

  def new
    @recipe = Recipe.new
    @recipe.ingredients.build
  end

  def edit
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      @recipe.image.purge_later if remove_image?
      redirect_to @recipe, notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy!
    redirect_to recipes_path, notice: "Recipe was successfully deleted.", status: :see_other
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  # Uploading a replacement wins over the remove checkbox, so a stale tick cannot
  # discard the file the user just chose.
  def remove_image?
    ActiveModel::Type::Boolean.new.cast(params.dig(:recipe, :remove_image)) &&
      params.dig(:recipe, :image).blank?
  end

  def recipe_params
    params.expect(
      recipe: [
        :title, :description, :servings, :prep_time_minutes, :cook_time_minutes, :instructions, :image, :remove_image,
        ingredients_attributes: [ [ :id, :name, :quantity, :unit, :_destroy ] ]
      ]
    )
  end
end
