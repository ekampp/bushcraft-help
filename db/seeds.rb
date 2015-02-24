require 'factory_girl_rails'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

User.create email: 'emil@kampp.me', password: 'hello', password_confirmation: 'hello'
FactoryGirl.create_list :article, 10
