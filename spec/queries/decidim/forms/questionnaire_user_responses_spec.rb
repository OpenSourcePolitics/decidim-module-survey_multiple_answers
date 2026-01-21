# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserResponses do
  subject { described_class.new(questionnaire) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }

  let!(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let!(:user1) { create(:user, organization: organization) }
  let!(:user2) { create(:user, organization: organization) }
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

  let!(:responses1) { questions.map { |question| create :response, session_token: :foo, user: user1, questionnaire: questionnaire, question: question } }
  let!(:responses2) { questions.map { |question| create :response, session_token: :bar, user: user1, questionnaire: questionnaire, question: question } }
  let!(:responses3) { questions.map { |question| create :response, session_token: :biz, user: user2, questionnaire: questionnaire, question: question } }

  context "when the survey allows multiple responses" do
    let(:settings) { { allow_multiple_answers: true } }

    it "returns the user answers for each user without the separators and title-and-descriptions" do
      result = subject.query

      expect(result.size).to eq(3)
      expect(result).to contain_exactly([responses1.last, responses1.first], [responses2.last, responses2.first], [responses3.last, responses3.first])
    end
  end

  context "when the survey does not allow multiple responses" do
    let(:settings) { { allow_multiple_answers: false } }

    it "returns the user answers for each user without the separators and title-and-descriptions" do
      result = subject.query

      expect(result.size).to eq(2)

      expect(result).to contain_exactly([responses3.last, responses3.first], [responses2.last, responses1.last, responses2.first, responses1.first])
    end
  end
end
