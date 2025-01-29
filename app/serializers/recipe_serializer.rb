# frozen_string_literal: true

class RecipeSerializer < Blueprinter::Base
  fields :name, :ingredients, :instructions
end
