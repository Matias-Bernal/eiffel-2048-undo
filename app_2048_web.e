note
	description: "[
						This class implements the `Hello World' service.
		
						It inherits from WSF_DEFAULT_RESPONSE_SERVICE to get default EWF connector ready
						only `response' needs to be implemented.
						In this example, it is redefined and specialized to be WSF_PAGE_RESPONSE
		
						`initialize' can be redefine to provide custom options if needed.
	]"

class
	APP_2048_WEB

inherit

	WSF_DEFAULT_RESPONSE_SERVICE
		redefine
			initialize
		end

create
	make_and_launch

feature

	controller: CONTROLLER_2048

	user_log_in: USER_2048_UNDO

	status: INTEGER
		-- 0 : Main Menu
		-- 1 : Login
		-- 2 : New User
		-- 3 : Play Game

	show_main_menu: BOOLEAN

	show_login: BOOLEAN

	show_new_user: BOOLEAN

	show_game: BOOLEAN


feature {NONE} -- Execution

	response (req: WSF_REQUEST): WSF_HTML_PAGE_RESPONSE
			-- Computed response message.
		do
			create Result.make

			--Result.add_javascript_url ("http://code.jquery.com/jquery-latest.min.js")
			Result.add_javascript_url ("https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js")
			Result.add_javascript_url ("https://ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js")
			--Result.add_javascript_url ("https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.js")
			Result.add_javascript_url ("https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js")

			if status = 0 then
				--Main Menu
				Result.set_title ("2048-UNDO / MAIN MENU")
				if(show_main_menu)then
					--Result.add_javascript_content ("function Login() {$.ajax({type : 'POST',url:'http://localhost:9999/',data:{option:'login'},contentType:'json',headers: {Accept :'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type':'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}")
					Result.set_body (print_html_main_menu)
					show_main_menu:=False
				else
					if attached req.string_item ("login") as o_login then
						if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
							if(login(nickname,password))then
								create user_log_in.make_existant_user (0,nickname , password, controller, false)

								Result.set_title ("2048-UNDO / USER: "+nickname.out)
								Result.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/',data:{message:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}})")
								Result.set_body (print_html_game)

								status := 3
							else
								Result.set_body (print_html_main_menu)
								Result.add_javascript_content ("alert('Invalid Nickname or Password')")
							end
						end
					end
					if attached req.string_item ("new_user")  as o_new_user then
						if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
							if(not existUser(nickname)) then
								create user_log_in.make_new_user (0, nickname, password)

								Result.set_title ("2048-UNDO / USER: "+nickname.out)
								Result.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/',data:{message:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}})")
								Result.set_body (print_html_game)

								status := 3
							else
								Result.set_body (print_html_main_menu)
								Result.add_javascript_content ("alert('User Already Exist')")
							end
						end
					end
				end
			elseif status = 3 then
				if(user_log_in /= Void) then
					if attached req.string_item ("message") as l_message then
						if l_message.is_equal ("up") then
							if controller.board.can_move_up then
								controller.up
							end
						elseif l_message.is_equal ("down") then
							if controller.board.can_move_down then
								controller.down
							end
						elseif l_message.is_equal ("left") then
							if controller.board.can_move_left then
								controller.left
							end
						elseif l_message.is_equal ("right") then
							if controller.board.can_move_right then
								controller.right
							end
						elseif l_message.is_equal ("undo") then
							if controller.can_undo_move then
								controller.undo
							end
						end
						if controller.board.is_winning_board then
							Result.add_javascript_content ("alert('YOU WON!!!!!!!!!!!!!!')")
							status := 0
						end
						if not controller.board.can_move_up and not controller.board.can_move_down and not controller.board.can_move_left and not controller.board.can_move_right then
							Result.add_javascript_content ("alert('YOU LOSE!!!!!!!!!!!!!!')")
							status := 0
						end
						Result.set_body (print_html_game)
					end
				else
					Result.add_javascript_content ("alert('Debe loguearse o crear un nuevo usuario')")
					show_main_menu:=True
				end
			end
		end

		print_html_main_menu: STRING
		do
			Result:="[
			<link rel="stylesheet" type="text/css" href="http://getbootstrap.com/examples/signin/signin.css">
			<link rel="stylesheet" type="text/css" href="http://quaxio.com/2048/style/main.css">
			<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
			<div align="center" class="container">
				<h1><span class="label label-default">2048-undo</span></h1>
				<br>
				<div class="user-container">
					<div align="center" class="container">
      					<form class="form-signin" form action="/" method="POST" role="form" id="649512336">
		        			<input type="nickname" name="nickname" class="form-control" placeholder="Nickname" required="" autofocus="">
        					<input type="password" name="password" class="form-control" placeholder="Password" required="">
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="login" value="Login"/>
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="new_user" value="New User"/>
      					</form>
					</div>
				</div>
				<div class="game-container">
					<div class="grid-container">
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
					</div>
				</div>
			</div>
				]"
		end

		print_html_game: STRING
		do
			Result:="[
			<link rel="stylesheet" type="text/css" href="http://getbootstrap.com/examples/signin/signin.css">
			<link rel="stylesheet" type="text/css" href="http://quaxio.com/2048/style/main.css">
			<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
			<div align="center" class="container">
				<h1><span class="label label-default">2048-undo</span></h1>
				<br>
				<div class="user-container">
					<div align="center" class="container">
      					<form class="form-signin" form action="/" method="POST" role="form" id="649512336">
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="save" value="Save"/>
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="exit" value="Exit"/>
      					</form>
					</div>
				</div>
				<div class="game-container">
					<div class="grid-container">
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
						<div class="grid-row">
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
							<div class="grid-cell"></div>
						</div>
					</div>
					<div class="tile-container">
						<div ng-app="" ng-init="points=[[2,3,5,6],[4,4,4,4],[8,8,8,8],[16,16,16,16]]">
							<div class="tile tile-2 tile-position-1-1 tile-new">
								<div class="tile-inner">{{ points[0][0] }}</div>
							</div>
							<div class="tile tile-2 tile-position-1-2 tile-new">
								<div class="tile-inner">{{ points[0][1] }}</div>
							</div>
							<div class="tile tile-2 tile-position-1-3 tile-new">
								<div class="tile-inner">{{ points[0][2] }}</div>
							</div>
							<div class="tile tile-2 tile-position-1-4 tile-new">
								<div class="tile-inner">{{ points[0][3] }}</div>
							</div>
							<div class="tile tile-2 tile-position-2-1 tile-new">
								<div class="tile-inner">{{ points[1][0] }}</div>
							</div>
							<div class="tile tile-2 tile-position-2-2 tile-new">
								<div class="tile-inner">{{ points[1][1] }}</div>
							</div>
							<div class="tile tile-2 tile-position-2-3 tile-new">
								<div class="tile-inner">{{ points[1][2] }}</div>
							</div>
							<div class="tile tile-2 tile-position-2-4 tile-new">
								<div class="tile-inner">{{ points[1][3] }}</div>
							</div>
							<div class="tile tile-2 tile-position-3-1 tile-new">
								<div class="tile-inner">{{ points[2][0] }}</div>
							</div>
							<div class="tile tile-2 tile-position-3-2 tile-new">
								<div class="tile-inner">{{ points[2][1] }}</div>
							</div>
							<div class="tile tile-2 tile-position-3-3 tile-new">
								<div class="tile-inner">{{ points[2][2] }}</div>
							</div>
							<div class="tile tile-2 tile-position-3-4 tile-new">
								<div class="tile-inner">{{ points[2][3] }}</div>
							</div>
							<div class="tile tile-2 tile-position-4-1 tile-new">
								<div class="tile-inner">{{ points[3][0] }}</div>
							</div>
							<div class="tile tile-2 tile-position-4-2 tile-new">
								<div class="tile-inner">{{ points[3][1] }}</div>
							</div>
							<div class="tile tile-2 tile-position-4-3 tile-new">
								<div class="tile-inner">{{ points[3][2] }}</div>
							</div>
							<div class="tile tile-2 tile-position-4-4 tile-new">
								<div class="tile-inner">{{ points[3][3] }}</div>
							</div>
						</div>
					</div>
				</div>
			</div>
				]"
		end

		login(nickname,password: STRING): BOOLEAN
		do
			Result:=True
		end

		existUser(nickname: STRING): BOOLEAN
		do
			Result:=True
		end

		add_user(nickname,password: STRING): BOOLEAN
		do
			Result:=True
		end

feature {NONE} -- Initialization

	initialize
		do
				--| Uncomment the following line, to be able to load options from the file ewf.ini
			create {WSF_SERVICE_LAUNCHER_OPTIONS_FROM_INI} service_options.make_from_file ("ewf.ini")
			create controller.make
			show_main_menu:=True
				--| You can also uncomment the following line if you use the Nino connector
				--| so that the server listens on port 9999
				--| quite often the port 80 is already busy
				--			set_service_option ("port", 9999)

				--| Uncomment next line to have verbose option if available
				--			set_service_option ("verbose", True)

				--| If you don't need any custom options, you are not obliged to redefine `initialize'
			Precursor
		end

end
