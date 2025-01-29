# frozen_string_literal: true

Groq.configure do |config|
  config.api_key = ENV.fetch("GROQ_API_KEY")
  config.model_id = ENV.fetch("GROQ_API_MODEL_ID", "llama3-70b-8192")
end
