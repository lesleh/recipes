# Recipes

A small Rails application for keeping recipes: what goes in them, how long they take,
and how to cook them. Recipes hold an ordered list of ingredients and a free-text
method, and can be searched by name, description or ingredient.

## Requirements

- Ruby 3.4.7 (see `.ruby-version`)
- SQLite 3

## Getting started

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

The application runs at <http://localhost:3000> and starts on the recipe list.
Seeding is optional and adds three sample recipes. It matches on title, so running
it more than once will not create duplicates.

## Tests and checks

```bash
bin/rails test
bin/rails test:system
bin/rubocop
bin/brakeman
bundle exec bundler-audit check --update
```

System tests drive headless Chrome through Selenium, which downloads a matching
driver on first run.

## Data model

A `Recipe` has a title, an optional description, servings, prep and cook times in
minutes, and a method stored as one step per line. It owns many `Ingredient`
records, each with a name and an optional quantity and unit, kept in an explicit
display order. Deleting a recipe deletes its ingredients.

Ingredients are edited inline on the recipe form. Rows are added and removed in the
browser by the `nested_form` Stimulus controller and saved through Active Record
nested attributes.

## Notes

The `json` gem is pinned below 3.0. Active Support 8.1 passes a positional options
hash to `JSON.parse`, which json 3.0 no longer accepts, and that breaks encrypted
cookie and session decoding. The pin can be lifted once Rails ships a fix.
