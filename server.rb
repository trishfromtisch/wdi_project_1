require "sinatra"
require "pry"
require "date"
require 'will_paginate'
require 'will_paginate/active_record'
require 'time'
require 'date'
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

	if params["view"] == "recent" || params["view"] == nil
		posts = Post.all.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		posts = Post.all.order(votes: :desc).paginate(:page => page, :per_page => 10)
	else
		posts = Post.all
		posts = posts.sort_by {|post| -post.comments.length}
		posts = posts.paginate(:page => page, :per_page => 10)
 	end

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
	
	if params["view"] == "recent" || params["view"] == nil
		comments = post.comments.order(id: :desc)
 	elsif params["view"] == "ranking"
		comments = post.comments.order(votes: :desc)
 	end

	authors = Author.all
	erb(:"posts/post", {locals: {post: post, comments: comments, authors: authors}})
end

post("/posts/:id/comment") do
	if params["author_type"] == "new"
		author = Author.create({handle: params["author"]})
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

	if params["view"] == "recent" || params["view"] == nil
		categories = Category.all.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		categories = Category.all.order(votes: :desc).paginate(:page => page, :per_page => 10)
	else
		categories = Category.all
		categories = categories.sort_by {|category| -categories.posts.length}
		categories = categories.paginate(:page => page, :per_page => 10)
 	end

	authors = Author.all
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

get("/categories/:name/posts") do 
	category = Category.find_by(name: params[:name])
	posts = category.posts
	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end

	posts_with_comments = []
	other_posts=[]
	posts.each do |post|
		if post.comments.length > 0
			posts_with_comments << post
		else
			other_posts << post
		end
	end
	posts_with_comments = posts_with_comments.sort_by {|post| - post.comments.length}
	total_posts  = []
	posts_with_comments.each {|post| total_posts << post}
	other_posts.each {|post| total_posts << post}



	if params["view"] == nil || params["view"] == "recent"
		posts = posts.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		posts = posts.order(votes: :desc).paginate(:page => page, :per_page => 10)
	elsif params["view"] == "active"
		total_posts.paginate(:page => page, :per_page => 10)
 	end
	erb(:"categories/category", {locals: {category: category, posts: posts}})
end


get("/categories/:name/new") do
	category = Category.find_by(name: params[:name])
	authors = Author.all
	erb(:"categories/new", {locals: {category: category, authors: authors}})
end

post("/categories/:name/new") do
	category = Category.find_by(name: params[:name])

	if params["author_type"] == "new"
		author = Author.create({handle: params["author"]})
	else
		author = Author.find_by(id: params["id"])
	end

	if params["give_expiration"] == "yes"
		case params["lifespan"] 
			when "3 months"
				expiration = DateTime.new >> 3
			when "1 month"
				expiration = DateTime.new >> 1
			when "2 weeks"
				expiration = DateTime.new + 14
			when "1 week"
				expiration = DateTime.new + 7
		end
	elsif params["give_expiration"] == "no"
		expiration = "294275-12-31 23:59:01 UTC"
	end

	Post.create({
		content: params["content"],
		title: params["title"],
		votes: 0,
		author_id: author.id,
		expiration: expiration,
		category_id: category.id
		})

	redirect "/categories/#{category.name}/posts"
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