# frozen_string_literal: true

module API
  module V1
    class RecipesController < BaseController
      def generate
        recipes = cook_book_service.synthesize_recipes(ingredients_params)
        render_json(recipes, RecipeSerializer)
      rescue CookBookService::MissUsageError => err
        render_error(error_code: "recipes_generator.miss_usage", message: err.message, status: :unprocessable_entity)
      end

      private

      def ingredients_params
        params.require(:ingredients)
      end

      def cook_book_service
        @cook_book_service ||= CookBookService.new
      end
    end
  end
end
