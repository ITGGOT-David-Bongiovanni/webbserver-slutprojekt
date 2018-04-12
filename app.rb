class App < Sinatra::Base
	enable :sessions

	get '/login' do
		slim(:login)
	end

	get '/' do
		slim(:start)
	end
	
	get '/register' do
		slim (:register)
	end

	get '/error' do
		slim(:error, locals:{msg:session[:message]})
	end	

	post '/login' do
		db = SQLite3::Database.new("db/databas.db")
		username = params["username"]
		password = params["password"]
		user_id = db.execute("SELECT id FROM users WHERE username='#{username}'")
		password_digest = db.execute("SELECT password FROM users WHERE username='#{username}'").join
		password_digest = BCrypt::Password.new(password_digest)
		if password_digest == password
			session[:username] = username
			session[:id] = user_id

			redirect('/list')
		else
			redirect('/register')
		end
	end

	post '/register' do
		db = SQLite3::Database.new("db/databas.db")
		username = params["username"]
		password = params["password"]
		password2 = params["password2"]
		telephone = params["telephone"]
		password_digest = BCrypt::Password.create("#{password}")
		if telephone.length > 0
			if username.length > 0
				if password == password2 && password.length > 0
					 begin
						db.execute("INSERT INTO users (username, password, telephone) VALUES (?, ?, ?)", [username,password_digest,telephone])
					 rescue
					 	session[:message] = "The username is potatis"
						redirect('/error')
					 end
					redirect('/login')
				else
					session[:message] = "Password unavailable"
					redirect('/error')
				end
			else
				session[:message] = "The username is unavailable"
				redirect('/error')
			end
		else
			session[:message] = "Telephone number is unavailable"
			redirect('/error')	
		end
	end

	get('/list') do
		db = SQLite3::Database.open("db/databas.db")
		if session[:id] == nil
			redirect('/login')
		else
			user_id = session[:id] 
			contacts = db.execute("SELECT username,telephone FROM users WHERE id IN (SELECT contact_id FROM contact WHERE user_id = ?)", [user_id])
			slim :list, locals:{contacts:contacts}
		end
	end
end           


          
