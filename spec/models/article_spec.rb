require 'rails_helper'

RSpec.describe Article, :type => :model do
  specify { expect(subject).to have_field :title }
  specify { expect(subject).to have_field :summary }
  specify { expect(subject).to have_field :content }
  specify { expect(subject).to have_field :updated_at }
  specify { expect(subject).to have_field :created_at }

  describe '#content=' do
    let(:subject) { build :article, summary: nil, content: nil }

    context 'summary already assigned' do
      before { subject.summary = 'hello' }

      it "doesn't override the summary" do
        subject.content = 'I am cool. So cool.'
        expect(subject.summary).to eql('hello')
      end
    end

    context "summary isn't assigned" do
      it 'assignes the summary as the first paragraph in the content' do
        subject.content = 'I am cool. So cool.'
        expect(subject.summary).to eql('I am cool')
      end
    end
  end

  describe '.unread_for' do
    let!(:articles) { create_list :article, 5 }
    let(:user) { create :user }
    subject { Article.unread_for(user) }

    it 'returns a collection of unread articles for supplied user' do
      articles[0..2].map { |a| a.reads.create(user: user) }
      expect(subject).to match_array(articles[3..5])
    end
  end

  describe '#read!' do
    subject { create :article }
    let(:user) { create :user }

    it 'marks the article as read by the user' do
      subject.read! user
      expect(subject.reads.map(&:user_id)).to include user.id
    end
  end

  describe '#read_by?' do
    subject { create :article }
    let(:user) { create :user  }

    it 'returns true when read by user' do
      subject.reads.create user: user
      expect(subject.read_by?(user)).to eql(true)
    end

    it 'returns false when not read by user' do
      expect(subject.read_by?(user)).to eql(false)
    end
  end
end
