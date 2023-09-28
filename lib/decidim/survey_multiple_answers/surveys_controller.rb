# frozen_string_literal: true

require "securerandom"

module Decidim
  module SurveyMultipleAnswers
    module SurveysController
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def self.prepended(base)
        base.class_eval do
          def allow_multiple_answers?
            permissions = [current_component.settings.try(:allow_multiple_answers?)]
            permissions << current_component.current_settings.try(:allow_multiple_answers?) if current_component.participatory_space.allows_steps?

            permissions.all?
          end

          # Public: return true if the current user (or session visitor) can answer the questionnaire
          def visitor_already_answered?
            return false if can_submit_multiple_answers?

            questionnaire.answered_by?(current_user || tokenize(session[:session_id]))
          end

          # token is used as a substitute of user_id if unregistered
          def session_token
            session_id = request.session[:session_id] if request&.session
            id = can_submit_multiple_answers? ? current_user&.id : SecureRandom.hex

            return nil unless id || session_id

            @session_token ||= tokenize(id || session_id)
          end

          def can_submit_multiple_answers?
            collaborator? && allow_multiple_answers?
          end

          def collaborator?
            return false unless current_user

            current_user.admin? ||
              current_participatory_space.user_roles(:admin).exists?(user: current_user) ||
              current_participatory_space.user_roles(:collaborator).exists?(user: current_user)
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
