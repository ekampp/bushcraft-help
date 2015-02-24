class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Before action filters.
  # Precendence is important. So please add specs if you change the order or add to the chain.
  before_action :authenticate
  before_action :set_tenancy
  before_action :auto_expose, if: :resource_names?
  before_action :cache, if: :cache?

  class << self
    attr_accessor :resource_names
    attr_accessor :cached_resources
  end

  private

    # Executed in an +after_action+ filter to automatically cache the page based on the exposed resources and explicitly
    # cached resources.
    def cache
      if resource_names?
        a = cached_resources.map { |name| send(name).max(:updated_at).to_s }
        Rails.logger.info { "Automatically caching #{controller_and_action} with keys: #{a.to_sentence}" }
        fresh_when a
      else
        expires_in 24.hours, public: true
      end
    rescue => e
      Bugsnag.notify(e)
      Rails.logger.warn do
        <<-EOS
Unable to automatically cache #{controller_and_action}.
It may have been cached otherwise, but you should ensure this manually!
Available resources: #{decent_exposures.keys.to_sentence}
        EOS
      end
    end

    # Helper method for fast access to controller#action identification.
    def controller_and_action
      "#{params[:controller]}##{params[:action]}"
    end

    # Automatically expose defined +resource_names+
    # This is done in a before filter, to allow teh resources to be available inside the action.
    def auto_expose
      resource_names.each do |name|
        unless decent_exposures[name].present?
          Rails.logger.debug { "Automatically exposing #{name}" }
          self.class.send(:expose, name)
        end
      end
    end

    def cache?
      true
    end

    def decent_exposures
      self.class._exposures
    end

    def resource_names?
      self.class.resource_names.present?
    end

    def cached_resources
      resource_names + (self.class.cached_resources || [])
    end

    def resource_names
      self.class.resource_names || []
    end

    def set_tenancy
      Mongoid::Multitenancy.current_tenant = current_user
    end

    def current_user
      raise StandardError, 'Unknown current user' unless @current_user
      @current_user
    end
    helper_method :current_user

    def authenticate
      if user = authenticate_with_http_basic { |e, p| User.where(email: e).first.authenticate(p) }
        @current_user = user.sign_in!
      else
        request_http_basic_authentication
      end
    rescue
      request_http_basic_authentication
    end
end
