require_relative "./connection.rb"
require_relative "./post.rb"
require_relative "./category.rb"

class Author < ActiveRecord::Base

	def posts
		Post.where(author_id: self.id)
	end

	def categories
		Category.where(author_id: self.id)
	end
end