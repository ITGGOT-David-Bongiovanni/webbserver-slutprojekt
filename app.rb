class App < Sinatra::Base
	enable :sessions

	get '/login' do
		slim(:login)
	end

	get '/start' do
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
		if username == "" or password == ""
			session[:message] = "Wrong Password or Username"
			redirect('/error')
		end
		begin
		user_id = db.execute("SELECT id FROM users WHERE username=?", [username])
		password_digest = db.execute("SELECT password FROM users WHERE username=?", [username]).join
		password_digest = BCrypt::Password.new(password_digest)
		rescue
			session[:message] = "Wrong Password or Username"
			redirect('/error')
		end
		if password_digest == password
			session[:username] = username
			session[:id] = user_id
			redirect('/list')
		else
			session[:message] = "Wrong Password or Username"
			redirect('/error')
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
			contacts = db.execute("SELECT username,telephone,id FROM users WHERE id IN (SELECT contact_id FROM contact WHERE user_id = ?)", [user_id])
			slim(:list, locals:{contacts:contacts})
		end
	end
	get ('/add') do
		db = SQLite3::Database.open("db/databas.db")
		if session[:id] == nil
			redirect('login')
		else
			user_id = session[:id]
			all = db.execute("SELECT username,telephone,id FROM users WHERE id IS NOT (?)", [user_id]) 
			# ändra så man inte får med favoriter
			slim(:add, locals:{all:all})
		end
	end
	post ('/add') do
		db = SQLite3::Database.open("db/databas.db")
		if session[:id] == nil
			redirect('login')
		else
			user_id = session[:id]
			contact_id = params["add_user_id"]
			db.execute("INSERT INTO contact (user_id, contact_id) VALUES (?,?)", [user_id, contact_id])
			redirect('/list')
		end
	end
	post('/remove') do
		db = SQLite3::Database.open("db/databas.db")
		if session[:id] == nil
			redirect('login')
		else
			user_id = session[:id]
			contact_id = params["add_user_id"]
			db.execute("DELETE FROM contact WHERE (user_id=? AND contact_id=?)", [user_id, contact_id])
			redirect('/list')
		end
	end
end           


          
