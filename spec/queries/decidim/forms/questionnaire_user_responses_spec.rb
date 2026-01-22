# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserResponses do
  subject { described_class.new(questionnaire) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }

  let!(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let!(:user_one) { create(:user, organization: organization) }
  let!(:user_two) { create(:user, organization: organization) }
  let!(:questions) do
    [
      create(:questionnaire_question, questionnaire: questionnaire, position: 3),
      create(:questionnaire_question, :separator, questionnaire: questionnaire, position: 2),
      create(:questionnaire_question, :title_and_description, questionnaire: questionnaire, position: 4),
      create(:questionnaire_question, questionnaire: questionnaire, position: 1)
    ]
  end

  let(:component) do
    create(:component, manifest_name: "surveys", participatory_space: participatory_process, organization: organization, settings: settings, step_settings: {
             participatory_process.active_step.id => { allow_multiple_answers: true }
           })
  end
  let!(:survey) { create(:survey, component: component) }

  let!(:responses_one) { questions.map { |question| create :response, session_token: :foo, user: user_one, questionnaire: questionnaire, question: question } }
  let!(:responses_two) { questions.map { |question| create :response, session_token: :bar, user: user_one, questionnaire: questionnaire, question: question } }
  let!(:responses_three) { questions.map { |question| create :response, session_token: :biz, user: user_two, questionnaire: questionnaire, question: question } }

  context "when the survey allows multiple responses" do
    let(:settings) { { allow_multiple_answers: true } }

    it "returns the user answers for each user without the separators and title-and-descriptions" do
      result = subject.query

      expect(result.size).to eq(3)
      expect(result).to contain_exactly([responses_one.last, responses_one.first], [responses_two.last, responses_two.first], [responses_three.last, responses_three.first])
    end
  end

  context "when the survey does not allow multiple responses" do
    let(:settings) { { allow_multiple_answers: false } }

    it "returns the user answers for each user without the separators and title-and-descriptions" do
      result = subject.query

      expect(result.size).to eq(2)

      expect(result).to contain_exactly([responses_three.last, responses_three.first], [responses_two.last, responses_one.last, responses_two.first, responses_one.first])
    end
  end
end
