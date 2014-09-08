require_relative "./connection.rb"
require_relative "./post.rb"
require_relative "./author.rb"

class Category < ActiveRecord::Base

	def posts
		Post.where(category_id: self.id)
	end

	def author
		Author.find_by(id: self.author_id)
	end
end