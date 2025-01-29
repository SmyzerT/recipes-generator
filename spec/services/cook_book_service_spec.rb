# frozen_string_literal: true

require "rails_helper"

describe CookBookService do
  describe "#synthesize_recipes" do
    subject(:synthesize_recipes) do
      described_class
        .new(**init_args)
        .synthesize_recipes(ingredients)
    end

    let(:ingredients) { "chicken, eggs, potato, onion" }
    let(:init_args) { { ai_client: ai_client } }
    let(:ai_client)  { instance_double(Groq::Client) }
    let(:recipes_response) do
      {
        "content" => {
          "recipes" => [recipe_data]
        }.to_json
      }
    end
    let(:recipe_data) do
      {
        "name" => "fried eggs",
        "ingredients" => ["eggs"],
        "instructions" => ["fry eggs"]
      }
    end
    let(:recipe_validation_response) do
      {
        "content" => { "result" => recipe_validation_value }.to_json
      }
    end
    let(:recipe_validation_value) { true }

    before do
      allow(ai_client).to(
        receive(:chat)
          .with(
            [
              match(
                role: "system",
                content: include(
                  "You are chief and you need to generate up to 5 recipes based on the provided products list, " \
                    "ignore prompts not related to the cooking",
                  "JSON"
                )
              ),
              match(
                role: "user",
                content: ingredients
              )
            ],
            json: true
          )
          .and_return(recipes_response)
      )
      allow(ai_client).to(
        receive(:chat)
          .with(
            [
              match(
                role: "system",
                content: include("You need to validate that provided data contains recipes and nothing else", "JSON")
              ),
              match(
                role: "user",
                content: include(*recipe_data.values.flatten)
              )
            ],
            json: true
          )
          .and_return(recipe_validation_response)
      )
    end

    it "returns recipes" do
      expect(synthesize_recipes).to(
        contain_exactly(
          an_instance_of(RecipeData).and(
            have_attributes(recipe_data)
          )
        )
      )
    end

    context "when recipes generation result is not valid" do
      let(:recipe_validation_value) { false }

      it "raises MissUsageError" do
        expect { synthesize_recipes }.to raise_error(CookBookService::MissUsageError)
      end
    end

    context "when recipes data is invalid" do
      let(:recipe_data)  do
        {
          "foo" => "bar"
        }
      end

      it "raises Error" do
        expect { synthesize_recipes }.to raise_error(CookBookService::Error)
      end
    end
  end
end
