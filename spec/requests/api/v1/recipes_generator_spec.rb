# frozen_string_literal: true

require "rails_helper"

describe "Recipes generator", type: :request do
  subject(:generate_recipes) do
    post "/api/v1/recipes/generate", params: params
  end

  let(:params) do
    {
      ingredients: "chicken, eggs, potato, onion"
    }
  end
  let(:cook_book_service) { instance_double(CookBookService) }
  let(:recipes) { [recipe] }
  let(:recipe) do
    RecipeData.new(
      name: "fried eggs",
      ingredients: ["eggs"],
      instructions: ["fry eggs"]
    )
  end

  before do
    allow(CookBookService).to(
      receive(:new)
        .and_return(cook_book_service)
    )
    allow(cook_book_service).to(
      receive(:synthesize_recipes)
        .with(params[:ingredients])
        .and_return(recipes)
    )
  end

  it "returns generated recipes" do
    generate_recipes

    expect(response).to have_http_status(:ok)
    json_response = JSON.parse(response.body)
    expect(json_response).to(
      match(
        "data" => contain_exactly(
          match(
            "name" => recipe.name,
            "ingredients" => recipe.ingredients,
            "instructions" => recipe.instructions
          )
        )
      )
    )
  end

  context "when miss using functionality" do
    before do
      allow(cook_book_service).to(
        receive(:synthesize_recipes)
          .with(params[:ingredients])
          .and_raise(CookBookService::MissUsageError, "Recipes can't be generated from the provided data")
      )
    end

    it "returns error message" do
      generate_recipes

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response).to(
        match(
          "error" => {
            "code" => "recipes_generator.miss_usage",
            "message" => "Recipes can't be generated from the provided data",
            "meta" => {}
          }
        )
      )
    end
  end
end
