require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  render_views

  describe 'authentication' do
    controller do
      def index
        render text: 'hello'
      end
    end

    context 'not present' do
      it 'denies access' do
        get :index
        expect(response.status).to eql(401)
      end
    end

    context 'incorrect' do
      it 'denies access' do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('a', 'password')
        get :index
        expect(response.status).to eql(401)
      end
    end

    context 'correctly' do
      before { http_login }

      it 'grants access' do
        get :index
        expect(response).to be_success
      end
    end
  end

  describe 'caching' do
    before { http_login }

    describe 'exposing no resources' do
      controller do
        def index
          render text: 'hello'
        end
      end

      it 'caches for 24 hours by default' do
        get :index
        expect(response.headers['Cache-Control']).to eql("max-age=#{24.hours.to_i}, public")
      end
    end

    describe 'exposing resources' do
      before { create_list :article, 10 }

      controller do
        self.resource_names = %i(articles)

        def index
          render text: 'hello'
        end
      end

      it 'caches using the last updated of the exposed resources' do
        expect(subject).to receive(:fresh_when).with([Article.last.updated_at.to_s])
        get :index
      end
    end

    describe 'handling exceptions' do
      controller do
        def index
          render text: 'hello'
        end
      end

      let(:e) { StandardError }

      it 'should notify bugsnag' do
        expect(Bugsnag).to receive(:notify).with(e)
        allow(subject).to receive(:expires_in).and_raise e
        expect(Rails.logger).to receive(:warn).and_call_original
        get :index
      end
    end
  end
end
