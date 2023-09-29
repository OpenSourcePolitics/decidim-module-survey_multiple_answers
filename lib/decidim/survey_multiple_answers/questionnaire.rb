# frozen_string_literal: true

module Decidim
  module SurveyMultipleAnswers
    module Questionnaire
      def self.prepended(base)
        base.class_eval do
          def questions_editable?
            (has_component? && !questionnaire_for.component.published?) || answers.empty?
          end

          def answered_by?(user)
            return false if allow_multiple_answers?

            query = user.is_a?(String) ? { session_token: user } : { user: user }

            answers.where(query).any? if questions.present?
          end

          def allow_multiple_answers?
            return false unless has_component?

            permissions = [questionnaire_for.component.settings.try(:allow_multiple_answers?)]
            permissions << questionnaire_for.component.current_settings.try(:allow_multiple_answers?) if questionnaire_for.component.participatory_space.allows_steps?

            permissions.all?
          end

          private

          def has_component?
            questionnaire_for.respond_to? :component
          end
        end
      end
    end
  end
end
