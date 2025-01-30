# frozen_string_literal: true

module API
  module V1
    class BaseController < ActionController::API
      private

      def render_json(data, serializer, status: :ok, root: "data")
        render json: serializer.render(data, root: root), status: status
      end

      def render_error(error_code:, message:, status: :internal_server_error, meta: {})
        error = {
          code: error_code,
          message: message,
          meta: meta
        }
        render json: { error: error }, status: status
      end
    end
  end
end
