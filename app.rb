require 'rubygems'
require 'sinatra'
# require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'motorcycled.db'
	@db.results_as_hash = true 
end

# before calling every time when app reloads (any page)

before do
	# initializing DB
	init_db
end

# configure calling every time while app is configuring:
# when code has been changed and page had to reload

configure do
	# initializing DB
	init_db

	# creates the table. If table doesn’t exists 

	@db.execute 'create table if not exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
	)'

	# creates the table. If table doesn’t exists 
	@db.execute 'create table if not exists Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer
	)'
end

get '/' do
	# choose list of posts from the DB

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

# handler of the get-request /new (browser getting the page from the server)

get '/new' do
	erb :new
end

# handler of the post-request /new (browser sending the data to the server)

post '/new' do
	# getting variable from post-request
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# saving data in DB

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	# redirect to the main page

	redirect to '/'
end

# output of the information about the post on forum

get '/details/:post_id' do

	# getting variable from url
	post_id = params[:post_id]

	# getting list of forum posts (there is will be only one post)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	# taking this one post and putting it in the variable @row
	@row = results[0]

	# choosing coments for this one post
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# returning details.erb
	erb :details
end

# request handler of the post-request /details/... (browser sends data to the server, and it’s being accepted here) 

post '/details/:post_id' do
	
	# getting variable from url
	post_id = params[:post_id]

	# getting variable from post-request
	content = params[:content]	

	# saves data in DB

	@db.execute 'insert into Comments
		(
			content,
			created_date,
			post_id
		)
			values
		(
			?,
			datetime(),
			?
		)', [content, post_id]

	# redirecting to the forum post page 

	redirect to('/details/' + post_id)
end