# frozen_string_literal: true

require "spec_helper"

describe "Admin manages survey compoenent", type: :system do
  let!(:user) do
    create :user,
           :admin,
           :confirmed,
           organization: organization
  end

  let(:organization) { participatory_space.organization }
  let(:participatory_space) { create(:participatory_process, :with_steps) }

  let!(:component) do
    create(:surveys_component,
           participatory_space: participatory_space,
           published_at: nil)
  end

  let(:help_label) do
    [
      "If active, a user will be able to answer the survey multiple times.",
      "This may lead to poor or unreliable data and it will be more vulnerable to automated attacks.",
      "Use with caution!"
    ]
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.components_path(participatory_space)
    click_link "Configure"
  end

  it "displays the correct label" do
    expect(page).to have_content("Allow multiple answers", count: 2)
  end

  it "displays the correct help label" do
    expect(page).to have_content(help_label.join(" "), count: 2)
  end
end
