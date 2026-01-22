# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "~> 0.31.0"

gem "decidim", DECIDIM_VERSION
gem "decidim-admin", DECIDIM_VERSION
gem "decidim-core", DECIDIM_VERSION
gem "decidim-survey_multiple_answers", path: "."

gem "bootsnap", "~> 1.7"
gem "faker", "~> 3.2"
gem "rspec", "3.13.0"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.7"
  gem "rubocop-faker", "~> 1.1"
  gem "spring", "~> 4.1"
  gem "spring-watcher-listen", "~> 2.1"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "codecov", require: false
end
