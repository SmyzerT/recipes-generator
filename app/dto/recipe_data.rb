# frozen_string_literal: true

class RecipeData < Dry::Struct
  SCHEMA = {
    type: "object",
    properties: {
      recipes: {
        type: "array",
        items: {
          type: "object",
          properties: {
            name: { type: "string" },
            ingredients: {
              type: "array",
              items: { type: "string" }
            },
            instructions: {
              type: "array",
              items: { type: "string" }
            }
          }
        }
      }
    }
  }.freeze

  transform_keys(&:to_sym)

  attribute :name, Dry::Types["string"]
  attribute :ingredients, Dry::Types["array"].of(Dry::Types["string"])
  attribute :instructions, Dry::Types["array"].of(Dry::Types["string"])
end
