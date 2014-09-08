require_relative "./connection.rb"
require_relative "./category.rb"
require_relative "./comment.rb"
require_relative "./author.rb"

class Post < ActiveRecord::Base

	def category
		Category.find_by({id: self.category_id})
	end

	def comments
		Comment.where({post_id: self.id})
	end

	def author
		Author.find_by({id: self.author_id})
	end
end