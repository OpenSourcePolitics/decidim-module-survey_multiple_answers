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
  let!(:questionnaire) { create(:questionnaire, title: title, description: description) }
  let!(:survey) { create(:survey, component: component, questionnaire: questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }

  include_context "with a component"

  context "when the survey allows multiple answers" do
    let(:last_answer) { questionnaire.answers.last }

    before do
      component.update!(
        settings: {
          allow_multiple_answers: true
        },
        step_settings: {
          component.participatory_space.active_step.id => {
            allow_multiple_answers: true,
            allow_answers: true,
            allow_unregistered: true
          }
        }
      )
    end

    it "allows answering the questionnaire" do
      visit_component

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      expect(questionnaire.answers.count).to eq(0)

      accept_confirm { click_button "Submit" }

      expect(questionnaire.answers.count).to eq(1)

      within ".success.flash" do
        expect(page).to have_content("Survey successfully answered")
      end

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      accept_confirm { click_button "Submit" }

      expect(questionnaire.answers.count).to eq(2)

      expect(last_answer.session_token).not_to be_empty
      expect(last_answer.ip_hash).not_to be_empty
    end
  end
end
