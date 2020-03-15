class Comment < ActiveRecord::Base
  has_attached_file :attachment
  has_attached_file :other_attachment
  validates :subject, :body, :presence => true
  validates_attachment :attachment, content_type: { content_type: /\Aimage\/.*\Z/ }
  validates_attachment :other_attachment, content_type: { content_type: 'text/plain' }
end
