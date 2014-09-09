require_relative "./connection.rb"
require_relative "./category.rb"
require_relative "./comment.rb"
require_relative "./author.rb"
require_relative "./subscriber.rb"

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

	def subscribers
		Subscriber.where({kind: "post", foreign_id: self.id})
	end

end