class Read
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: BSON::ObjectId

  embedded_in :article

  def user=(user)
    self.user_id = user.id
  end
end
