class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :password_digest, type: String
  field :email, type: String
  field :last_signed_in, type: ActiveSupport::TimeWithZone

  has_secure_password

  # Updates the user's login related information, such as the last_signed_in time etc.
  # Returns self for chaining.
  def sign_in!
    self.last_signed_in = Time.zone.now
    self
  end
end
