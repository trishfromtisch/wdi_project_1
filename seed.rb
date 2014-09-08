require_relative "./lib/category.rb"
require_relative "./lib/comment.rb"
require_relative "./lib/connection.rb"
require_relative "./lib/post.rb"
require_relative "./lib/subscriber.rb"
require_relative "./lib/author.rb"


Category.create({
	name: "happy_hour",
	description: "Suggest bars, vote on your favorites.",
	votes: 0,
	has_post: true
	})

Category.create({
	name: "day_trips",
	description: "Propose outtings, vote on your favorites, share your protips.",
	votes: 0,
	has_post: false
	})

Category.create({
	name: "cooks",
	description: "Post Sunday dinner dates and special events that need cooks, sign up to volunteer.",
	votes: 0,
	has_post: false
	})

Post.create({
	content: "Let's all go to McSorley's next Friday. Cheese plates and lights FTW!",
	category_id: 1,
	expiration: "2014-09-13 03:14:07",
	votes: 5,
	title: "McSorley's Fri 9/12",
	author_id: 1
	})

Comment.create({
	content: "Love it!",
	post_id: 1,
	author_id: 1,
	votes: 0
	})

Author.create({
	handle: "Trish"
	})

