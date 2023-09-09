# frozen_string_literal: true

require "spec_helper"

describe "Private Space Answer a survey", type: :system do
  let(:manifest_name) { "surveys" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }

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

  let!(:organization) { create(:organization) }
  let!(:another_user) { create(:user, :confirmed, organization: organization) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: another_user, privatable_to: participatory_space_private) }
  let!(:questionnaire) { create(:questionnaire, title: title, description: description) }
  let!(:survey) { create(:survey, component: component, questionnaire: questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }

  let!(:participatory_space) { participatory_space_private }

  let!(:component) { create(:component, manifest: manifest, participatory_space: participatory_space) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { allow_answers: true })
  end

  def visit_component
    page.visit main_component_path(component)
  end

  context "when space is private and transparent" do
    let!(:participatory_space_private) { create(:assembly, :published, organization: organization, private_space: true, is_transparent: true) }

    context "when the user is logged in" do
      context "and is private user space" do
        before do
          login_as another_user, scope: :user
        end

        context "when the survey does not allow multiple answers" do
          it "allows answering the survey" do
            visit_component

            expect(page).to have_i18n_content(questionnaire.title)
            expect(page).to have_i18n_content(questionnaire.description)

            fill_in question.body["en"], with: "My first answer"

            check "questionnaire_tos_agreement"

            accept_confirm { click_button "Submit" }

            within ".success.flash" do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_content("You have already answered this form.")
            expect(page).to have_no_i18n_content(question.body)
          end
        end

        context "when the survey allows multiple answers" do
          let(:last_answer) { questionnaire.answers.last }

          before do
            component.update!(
              settings: {
                allow_multiple_answers: true,
                allow_answers: true
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
    end
  end
end
