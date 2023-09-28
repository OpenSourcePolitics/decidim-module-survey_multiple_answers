# frozen_string_literal: true

require "rails"
require "decidim/core"
require "decidim/survey_multiple_answers/questionnaire"
require "decidim/survey_multiple_answers/surveys_controller"
require "decidim/survey_multiple_answers/questionnaire_user_answers"

module Decidim
  module SurveyMultipleAnswers
    # This is the engine that runs on the public interface of survey_multiple_answers.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SurveyMultipleAnswers

      routes do
        # Add engine routes here
        # resources :survey_multiple_answers
        # root to: "survey_multiple_answers#index"
      end

      initializer "decidim_survey_multiple_answers.override" do |app|
        app.config.to_prepare do
          Decidim::Forms::Questionnaire.prepend Decidim::SurveyMultipleAnswers::Questionnaire
          Decidim::Forms::QuestionnaireUserAnswers.prepend Decidim::SurveyMultipleAnswers::QuestionnaireUserAnswers
          ActiveSupport.on_load :action_controller do
            Decidim::Surveys::SurveysController.prepend Decidim::SurveyMultipleAnswers::SurveysController
          end
        end
      end

      initializer "decidim_survey_multiple_answers.append_options" do |app|
        app.config.to_prepare do
          Decidim.find_component_manifest(:surveys).settings(:global) do |settings|
            settings.attribute :allow_multiple_answers, type: :boolean, default: false
          end

          Decidim.find_component_manifest(:surveys).settings(:step) do |settings|
            settings.attribute :allow_multiple_answers, type: :boolean, default: false
          end
        end
      end
    end
  end
end
