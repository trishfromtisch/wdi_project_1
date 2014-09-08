require "sinatra"
require "pry"
require "date"
require 'will_paginate'
require 'will_paginate/active_record'
require_relative "./lib/connection.rb"
require_relative "./lib/category.rb"
require_relative "./lib/comment.rb"
require_relative "./lib/post.rb"
require_relative "./lib/subscriber.rb"
require_relative "./lib/author.rb"

after do
	ActiveRecord::Base.connection.close
end

get("/") do
	erb(:index)
end

get("/posts") do
	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end

	posts = Post.all.order(id: :desc).paginate(:page => page, :per_page => 10)
 	
 	erb(:"posts/posts", {locals: {posts: posts}})
 end

get("/posts/popular") do
	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end
	posts = Post.all.order(votes: :desc).paginate(:page => page, :per_page => 10)
 	erb(:"posts/posts", {locals: {posts: posts}})
end

put("/posts/:id") do
	post = Post.find_by(id: params[:id])
	if params["vote"] == "up"
		vote = post.votes + 1
	else
		vote = post.votes - 1
	end
	post.update({votes: vote})

	redirect request.referer
end

get("/posts/:id") do
	post = Post.find_by(id: params[:id])
	authors = Author.all
	erb(:"posts/post", {locals: {post: post, authors: authors}})
end

post("/posts/:id/comment") do
	if params["author_type"] == "new"
		author = Author.create({
			handle: params["author"]
			})
	else
		author = Author.find_by(id: params["id"])
	end
	
	Comment.create({
		content: params["content"],
		post_id: params[:id],
		author_id: author.id,
		votes: 0
		})
	redirect request.referer
end

put("/comments/:id") do
	comment = Comment.find_by(id: params[:id])
	if params["vote"] == "up"
		vote = comment.votes + 1
	else
		vote = comment.votes - 1
	end
	comment.update({votes: vote})
	redirect request.referer
end

get("/categories") do 
	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end

	authors = Author.all
	categories = Category.all.order(id: :desc).paginate(:page => page, :per_page => 10)
	erb(:"categories/categories", {locals: {categories: categories, authors: authors}})
end

get("/categories/popular") do 
	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end

	authors = Author.all
	categories = Category.all.order(votes: :desc).paginate(:page => page, :per_page => 10)
	erb(:"categories/categories", {locals: {categories: categories, authors: authors}})
end

post("/categories") do
	if params["author_type"] == "new"
		author = Author.create({handle: params["author"]})
	else
		author = Author.find_by(id: params["id"])
	end

	Category.create({
		name: params["name"],
		description: params["description"],
		author_id: author.id,
		votes: 0,
		has_post: false
		})
	redirect request.referer
end 

put("/categories/:id") do
	category = Category.find_by(id: params[:id])
	if params["vote"] == "up"
		vote = category.votes + 1
	else
		vote = category.votes - 1
	end
	category.update({votes: vote})

	redirect request.referer
end

delete("/categories/:id") do
	category = Category.find_by(id: params[:id])
	category.destroy
	redirect request.referer
end

get("authors/:id") do
	author = Author.find_by(id: params[:id])
	erb(:"authors/author", {locals: {author: author}})
	end


# 	shows individual post, links to category
# 	has a form to upvote, downvote, or create subscription
# 	shows comments
# 	For active posts:
# 		has a form to upvote, downvote, or create subscription
# 		has a form to comment
# 	For expired posts:
# 		show post on a different erb without form, says it's expired