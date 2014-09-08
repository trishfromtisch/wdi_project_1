require_relative "./connection.rb"
require_relative "./author.rb"

class Comment < ActiveRecord::Base

	def author
		Author.find_by(id: self.author_id)
	end
end