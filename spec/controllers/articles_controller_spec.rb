require 'rails_helper'

RSpec.describe ArticlesController, :type => :controller do
  specify { expect(subject.class.resource_names).to match_array(%i(articles)) }
end
