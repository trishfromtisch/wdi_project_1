require 'httparty'

params = {
    from: "Mailgun Sandbox <postmaster@gradlaw.com>", 
    to: "Trish <parlaws@gmail.com>", 
    subject: "Hello Trish", 
    text: "Congratulations Trish"
}

url = "https://api.mailgun.net/v2/sandbox34f4160a9bf44d4db304b02b3c8153f4.mailgun.org/messages"
auth = {:username=>"api", :password=>"key-7b0126ef47a1c80b2c76ca44e9cbc5fc"}

HTTParty.post(url, {body: params, basic_auth: auth})

sandbox34f4160a9bf44d4db304b02b3c8153f4.mailgun.org