# frozen_string_literal: true

module Decidim
  module SurveyMultipleAnswers
    module QuestionnaireUserResponses
      def self.prepended(base)
        base.class_eval do
          # Finds and group answers by user for each questionnaire's question.
          def query
            responses = Decidim::Forms::Response.not_separator
                                                .not_title_and_description
                                                .joins(:question)
                                                .where(questionnaire: @questionnaire)

            if @questionnaire.allow_multiple_answers?
              responses.sort_by { |response| response.question.position.to_i }.group_by(&:session_token).values
            else
              responses.sort_by { |response| response.question.position.to_i }.group_by { |a| a.user || a.session_token }.values
            end
          end
        end
      end
    end
  end
end
