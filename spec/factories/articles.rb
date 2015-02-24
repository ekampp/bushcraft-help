FactoryGirl.define do
  factory :article do
    title { Faker::Lorem.words.join(' ') }
    content { Faker::Lorem.sentences(10).join("\n\n") }
  end
end
