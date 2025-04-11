# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/survey_multiple_answers/version"

Gem::Specification.new do |s|
  s.version = Decidim::SurveyMultipleAnswers.version
  s.authors = ["Alexandru Emil Lupu"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-survey_multiple_answers"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-survey_multiple_answers"
  s.summary = "A decidim module that allows you to submit multiple answers to a survey"
  s.description = "A decidim module that allows you to submit multiple answers to a survey"

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", ">= 0.26.0", "< 0.30.0"
  s.add_dependency "decidim-core", ">= 0.26.0", "< 0.30.0"
  s.add_dependency "decidim-forms", ">= 0.26.0", "< 0.30.0"
  s.add_dependency "decidim-surveys", ">= 0.26.0", "< 0.30.0"
  s.add_development_dependency "decidim-participatory_processes", ">= 0.26.0", "< 0.30.0"
  s.metadata["rubygems_mfa_required"] = "true"
end
