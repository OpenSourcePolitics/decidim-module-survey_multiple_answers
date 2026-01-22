# frozen_string_literal: true

require "spec_helper"

describe "Answer a survey", type: :system do
  let(:manifest_name) { "surveys" }

  let(:title) do
    {
      "en" => "SURVEY'S TITLE",
      "ca" => "Títol de l'enquesta'",
      "es" => "Título de la encuesta"
    }
  end
  let(:description) do
    {
      "en" => "<p>Survey's content</p>",
      "ca" => "<p>Contingut de l'enquesta</p>",
      "es" => "<p>Contenido de la encuesta</p>"
    }
  end
  let(:question_description) do
    {
      "en" => "<p>Survey's content</p>",
      "ca" => "<p>Contingut de l'enquesta</p>",
      "es" => "<p>Contenido de la encuesta</p>"
    }
  end
  let!(:questionnaire) { create(:questionnaire, title: title, description: description) }
  let!(:survey) { create(:survey, :published, component: component, questionnaire: questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0, description: question_description) }

  include_context "with a component"

  context "when the survey allow responses" do
    context "when the survey allows multiple responses" do
      let(:first_response) { questionnaire.responses.first }
      let(:last_response) { questionnaire.responses.last }

      before do
        survey.update!(allow_responses: true, allow_unregistered: true, starts_at: 1.week.ago, ends_at: 1.day.from_now)
        component.update!(
          step_settings: {
            component.participatory_space.active_step.id => {
              allow_multiple_answers: true
            }
          },
          settings: {
            allow_multiple_answers: true
          }
        )
      end

      def answer_survey
        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)

        fill_in question.body["en"], with: "My first answer"

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }
      end

      it "allows answering the questionnaire" do
        visit_component
        click_on translated_attribute(questionnaire.title)

        expect(questionnaire.responses.count).to eq(0)

        answer_survey
        sleep 2
        expect(questionnaire.responses.reload.count).to eq(1)

        within ".success.flash" do
          expect(page).to have_content("Survey successfully responded.")
        end

        answer_survey
        sleep 2
        expect(questionnaire.responses.reload.count).to eq(2)

        expect(last_response.session_token).not_to be_empty
        expect(last_response.ip_hash).not_to be_empty

        expect(first_response.session_token).not_to eq(last_response.session_token)
        expect(first_response.ip_hash).to eq(last_response.ip_hash)
      end
    end
  end
end
