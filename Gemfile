# frozen_string_literal: true

source 'https://rubygems.org'

gem 'avatax-ruby', '0.1.3', github: 'whitespectre/avatax', branch: 'adn'

gem 'solidus_auth_devise'

gem 'factory_bot', '~> 4.8'

case ENV['DB']
when 'postgres'
  gem 'pg'
when 'mysql'
  gem 'mysql2'
else
  gem 'sqlite3', '~> 1.4'
end

gemspec
