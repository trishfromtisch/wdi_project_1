require 'httparty'
require_relative "./connection.rb"
require_relative "./post.rb"
require_relative "./category.rb"

class Subscriber < ActiveRecord::Base

	def send_post_email(title, message, author)
		params = {
		    from: "GradLaw Forum <postmaster@gradlaw.com>", 
		    to: "<#{self.email}>", 
		    subject: "GradLaw Update - New comment in #{title}", 
		    text: "#{message} \n Written by #{author}"
		}

		url = "https://api.mailgun.net/v2/sandbox34f4160a9bf44d4db304b02b3c8153f4.mailgun.org/messages"
		auth = {:username=>"api", :password=>"key-7b0126ef47a1c80b2c76ca44e9cbc5fc"}

		HTTParty.post(url, {body: params, basic_auth: auth})
	end

	def send_category_email(title, message, author)
		params = {
		    from: "GradLaw Forum <postmaster@gradlaw.com>", 
		    to: "<#{self.email}>", 
		    subject: "GradLaw Update - New post in #{title}", 
		    text: "#{message} \n Posted by #{author}"
		}

		url = "https://api.mailgun.net/v2/sandbox34f4160a9bf44d4db304b02b3c8153f4.mailgun.org/messages"
		auth = {:username=>"api", :password=>"key-7b0126ef47a1c80b2c76ca44e9cbc5fc"}

		HTTParty.post(url, {body: params, basic_auth: auth})
	end

end