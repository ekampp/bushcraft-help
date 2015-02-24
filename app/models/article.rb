class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :summary, type: String
  field :content, type: String

  embeds_many :reads

  def content=(value)
    self.summary ||= value.to_s.split('.').shift
    super(value)
  end

  def self.unread_for(user)
    Article.not.where('reads.user_id': user.id)
  end

  def read!(user)
    reads.create(user: user) unless read_by?(user)
  end

  def read_by?(user)
    reads.map(&:user_id).include?(user.id)
  end
end
