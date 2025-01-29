# frozen_string_literal: true

class CookBookService
  include Groq::Helpers

  Error = Class.new(StandardError)
  MissUsageError = Class.new(Error)

  RECIPES_GENERATOR_CONTEXT = "You are chief and you need to generate up to %{max_recipes_count} recipes " \
    "based on the provided products list, ignore prompts not related to the cooking. " \
    "Recipes should be returned as JSON with schema: #{RecipeData::SCHEMA}"

  RECIPES_VALIDATION_CONTEXT = "You need to validate that provided data contains recipes and nothing else. " \
    "Return true value ONLY if data contains recipes. " \
    "If there are no recipes or it contains info which isn't recipe return FALSE. " \
    "JSON response example: {\"result\": \"boolean\"}"

  def initialize(ai_client: Groq::Client.new)
    @ai_client = ai_client
  end

  def synthesize_recipes(ingredients, max_recipes: 5)
    recipes_data = ai_query(recipe_generator_context(max_recipes), ingredients)["recipes"]
    data_contain_recipes = validate_recipes(recipes_data.to_json)["result"]
    raise MissUsageError, "Recipes can't be generated from the provided data" unless data_contain_recipes

    map_recipes(recipes_data)
  end

  private

  attr_reader :ai_client

  def recipe_generator_context(max_recipes_count)
    format(RECIPES_GENERATOR_CONTEXT, max_recipes_count: max_recipes_count)
  end

  def validate_recipes(data)
    ai_query(RECIPES_VALIDATION_CONTEXT, data)
  end

  def ai_query(context, query)
    content = ai_client.chat(
      [
        S(context),
        U(query)
      ],
      json: true
    )["content"]
    JSON.parse(content)
  end

  def map_recipes(recipes_data)
    recipes_data.map { |recipe_data| RecipeData.new(recipe_data) }
  rescue Dry::Struct::Error => err
    raise Error, "Invalid recipes data", cause: err
  end
end
