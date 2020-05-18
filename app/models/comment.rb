class Comment < ApplicationRecord
  include ShortId
  include Comments::TreeMethods

  belongs_to :user
  belongs_to :submission
  belongs_to :parent, optional: true, class_name: "Comment"

  def self.short_id_prefix
    :c_
  end
end
