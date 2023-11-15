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
  let!(:survey) { create(:survey, component: component, questionnaire: questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0, description: question_description) }

  include_context "with a component"

  context "when the survey allow answers" do
    context "when the survey allows multiple answers" do
      let(:first_answer) { questionnaire.answers.first }
      let(:last_answer) { questionnaire.answers.last }

      before do
        component.update!(
          step_settings: {
            component.participatory_space.active_step.id => {
              allow_answers: true,
              allow_unregistered: true,
              allow_multiple_answers: true
            }
          },
          settings: {
            starts_at: 1.week.ago,
            ends_at: 1.day.from_now,
            allow_multiple_answers: true
          },
        )
      end

      def answer_survey
        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)

        fill_in question.body["en"], with: "My first answer"

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }
      end

      it "allows answering the questionnaire" do
        visit_component

        expect(questionnaire.answers.count).to eq(0)

        answer_survey

        expect(questionnaire.answers.count).to eq(1)

        within ".success.flash" do
          expect(page).to have_content("Survey successfully answered")
        end

        answer_survey

        expect(questionnaire.answers.count).to eq(2)

        expect(last_answer.session_token).not_to be_empty
        expect(last_answer.ip_hash).not_to be_empty

        expect(first_answer.session_token).not_to eq(last_answer.session_token)
        expect(first_answer.ip_hash).to eq(last_answer.ip_hash)
      end
    end
  end
end
