require 'rails_helper'

RSpec.describe User, :type => :model do
  specify { expect(subject).to respond_to(:authenticate) }

  describe '#sign_in!' do
    subject { User.new }
    before do
      subject.sign_in!
      Timecop.freeze
    end
    after { Timecop.return }

    specify { expect(subject.last_signed_in.to_s).to eql(Time.zone.now.to_s) }
  end
end
