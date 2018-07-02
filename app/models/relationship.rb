class Relationship < ApplicationRecord
	belongs_to :followed, class_name: "User"
	belongs_to :follower, class_name: "User"

	# as of Rails 5, these two below can be omitted
	validates :followed_id, presence: true 
	validates :follower_id, presence: true

end
