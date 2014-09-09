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
		posts = Post.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		posts = Post.order(votes: :desc).paginate(:page => page, :per_page => 10)
	else
		posts = Post.order(comment_tally: :desc).paginate(:page => page, :per_page => 10)
 	end

 	active_posts = []
 	posts.each do |post|
 		if post.expiration.to_i > DateTime.now.to_i
 			active_posts << post
 		end
 	end

 	posts = active_posts

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
	post = Post.find_by(id: params[:id])
	
	if params["author_type"] == "new"
		author = Author.create({handle: params["author"]})
	elsif params["author_type"] == "old"
		author = Author.find_by(id: params["author_id"])
	end

	
	comment = Comment.create({
		content: params["content"],
		post_id: post.id,
		author_id: author.id,
		votes: 0
		})

	new_tally = post.comment_tally + 1
	post.update(comment_tally: new_tally)

	if post.subscribers != nil
		post.subscribers.each do |subscriber|
		subscriber.send_post_email(post.title, comment.content, comment.author.handle)
		end
	end

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
		categories = Category.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		categories = Category.order(votes: :desc).paginate(:page => page, :per_page => 10)
	else
		categories = Category.order(post_tally: :desc).paginate(:page => page, :per_page => 10)
 	end

	authors = Author.all
	erb(:"categories/categories", {locals: {categories: categories, authors: authors}})
end

post("/categories") do
	if params["author_type"] == "new"
		author = Author.create({handle: params["author"]})
	elsif params["author_type"] == "old"
		author = Author.find_by(id: params["author_id"])
	end

	Category.create({
		name: params["name"],
		description: params["description"],
		author_id: author.id,
		votes: 0,
		has_post: false,
		post_tally: 0
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

	if params["page"] == nil
		page = 1
	else
		page = params["page"].to_i
	end

	if params["view"] == nil || params["view"] == "recent"
		posts = category.posts.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		posts = category.posts.order(votes: :desc).paginate(:page => page, :per_page => 10)
	elsif params["view"] == "active"
		posts = category.posts.order(comment_tally: :desc).paginate(:page => page, :per_page => 10)
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

	post = Post.create({
		content: params["content"],
		title: params["title"],
		votes: 0,
		author_id: author.id,
		expiration: expiration,
		category_id: category.id,
		comment_tally: 0
		})
	
	new_tally = category.post_tally + 1
	category.update(post_tally: new_tally)

	if category.subscribers != nil
		category.subscribers.each do |subscriber|
		subscriber.send_category_email(category.title, post.content, post.author.handle)
		end
	end

	redirect "/categories/#{category.name}/posts"
end

get("/authors/:id") do
	author = Author.find_by(id: params[:id])

	if params["sort_kind"] == nil && author.categories.length == 0
		posts = author.posts.order(id: :desc)
	elsif params["sort_kind"] == nil && author.posts.length == 0
		categories = author.categories.order(id: :desc)
	elsif params["sort_kind"] == nil && author.categories.length >= 1 && author.posts.length >= 1
		categories = author.categories.order(id: :desc)
		posts = author.posts.order(id: :desc)
	elsif 	
		params["sort_kind"] == "category"
		if params["view"] == nil || params["view"] == "recent"
			categories = author.categories.order(id: :desc)
	 	elsif params["view"] == "ranking"
			categories = author.categories.order(votes: :desc)
		elsif params["view"] == "active"
			categories = author.categories.order(comment_tally: :desc)
		end
 	elsif params["sort_kind"] == "post"
		if params["view"] == nil || params["view"] == "recent"
			posts = author.posts.order(id: :desc)
	 	elsif params["view"] == "ranking"
			posts = author.posts.order(votes: :desc)
		elsif params["view"] == "active"
			posts = author.posts.order(comment_tally: :desc)
		end
	end
	
	if author.categories.length == 0 && author.posts.length >= 1
		erb(:"authors/author", {locals: {author: author, posts: posts}})
	elsif author.categories.length >= 1 && author.posts.length == 0
		erb(:"authors/author", {locals: {author: author, categories: categories}})
	else 
		erb(:"authors/author", {locals: {author: author, posts: posts, categories: categories}})
	end

end

post("/subscribe/:kind/:id/") do
	Subscriber.create({
		email: params["email"],
		kind: params[:kind],
		foreign_id: params[:id]
		})
	redirect request.referer
end

get("/archive") do 
	if params["view"] == nil || params["view"] == "recent"
		posts = Post.order(id: :desc).paginate(:page => page, :per_page => 10)
 	elsif params["view"] == "ranking"
		posts = Post.order(votes: :desc).paginate(:page => page, :per_page => 10)
	elsif params["view"] == "active"
		posts = Post.order(comment_tally: :desc).paginate(:page => page, :per_page => 10)
 	end

	erb(:archive, {locals: {posts: posts}})
end

