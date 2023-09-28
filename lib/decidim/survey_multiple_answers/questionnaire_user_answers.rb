# frozen_string_literal: true

module Decidim
  module SurveyMultipleAnswers
    module QuestionnaireUserAnswers
      def self.prepended(base)
        base.class_eval do
          # Finds and group answers by user for each questionnaire's question.
          def query
            answers = Decidim::Forms::Answer.not_separator
                                            .not_title_and_description
                                            .joins(:question)
                                            .where(questionnaire: @questionnaire)

            if @questionnaire.allow_multiple_answers?
              answers.sort_by { |answer| answer.question.position }.group_by(&:session_token).values
            else
              answers.sort_by { |answer| answer.question.position }.group_by { |a| a.user || a.session_token }.values
            end
          end
        end
      end
    end
  end
end
