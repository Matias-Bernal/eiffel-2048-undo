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

			Result.add_javascript_url ("https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js")
			Result.add_javascript_url ("https://ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js")
			--Result.add_javascript_url ("https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.js")
			Result.add_javascript_url ("https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js")
			Result.add_javascript_content("function getChoice(keyCode){var ret='';if (keyCode == 119)ret = 'up';if (keyCode == 115)ret = 'down';if (keyCode == 100)ret = 'right';if (keyCode == 97)ret = 'left';return ret;}")
			Result.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/',data:{message:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();eval(document);})}})")
			if status = 0 then
				--Main Menu
				Result.set_title ("2048-UNDO / MAIN MENU")
				if(show_main_menu)then
					Result.set_body (print_html_main_menu)
					show_main_menu:=False
				else
					if attached req.string_item ("login") as o_login then --SI SE LOGUEA
						if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
							if(login(nickname,password))then
								user_log_in.load_game
								if(user_log_in.has_unfinished_game)then
									controller := user_log_in.game
								end
								Result.set_title ("2048-UNDO / USER: "+nickname.as_upper.out) --MOSTAR EL JUEGO
								Result.add_javascript_content (load_board)
								Result.set_body (print_html_game)
								status := 3
							else
								Result.set_body (print_html_main_menu)
								Result.add_javascript_content ("alert('Invalid Nickname or Password')")
							end
						end
					end
					if attached req.string_item ("new_user")  as o_new_user then -- HACE UN USUARIO NUEVO
						if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
							if(not login(nickname,password))then
								create user_log_in.make_new_user (nickname, password, controller)
								user_log_in.save_game (controller)

								Result.set_title ("2048-UNDO / USER: "+nickname.as_upper.out) --MOSTRAR EL JUEGO
								Result.add_javascript_content (load_board)
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
					if attached req.string_item ("save")  as o_new_user then
						user_log_in.save_game (controller)
						Result.set_title ("2048-UNDO / MAIN MENU")
						Result.set_body (print_html_main_menu)
						create controller.make
						status := 0
						user_log_in := Void
					end
					if attached req.string_item ("exit")  as o_new_user then
						Result.set_title ("2048-UNDO / MAIN MENU")
						Result.set_body (print_html_main_menu)
						create controller.make
						status := 0
						user_log_in := Void
					end
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
						Result.add_javascript_content (load_board)
						Result.set_body (print_html_game)
						if controller.board.is_winning_board then
							Result.add_javascript_content ("alert('YOU WON!!!!!!!!!!!!!!')")
							status := 0
						end
						if not controller.board.can_move_up and not controller.board.can_move_down and not controller.board.can_move_left and not controller.board.can_move_right then
							Result.add_javascript_content ("alert('YOU LOSE!!!!!!!!!!!!!!')")
							status := 0
						end
					end
				else
					Result.add_javascript_content ("alert('Select User or Create a New User')")
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
				<h1><span class="label label-default">2048-Undo</span></h1>
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
				<h1><span class="label label-default">2048-Undo</span></h1>
				<br>
				<div class="user-container">
					<div align="center" class="container">
      					<form class="form-signin" form action="/" method="POST" role="form" id="649512336">
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="save" value="Save Game & Exit"/>
        					<input type="submit" class="btn btn-lg btn-primary btn-block" name="exit" value="Exit"/>
      					</form>
					</div>
				</div>
				<p>Join the numbers and get to the 2048 tile!</p>
				<p>Hit 'Z' to take back one or more moves</p>
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
						<div ng-app="myapp" ng-controller="GameController">
						<div class="tile tile-2 tile-position-1-1 tile-new ">
							<div class="tile-inner" ng-bind="cell_1_1"></div>
						</div>
						<div class="tile tile-2 tile-position-1-2 tile-new">
							<div class="tile-inner" ng-bind="cell_1_2"></div>
						</div>
						<div class="tile tile-2 tile-position-1-3 tile-new">
							<div class="tile-inner" ng-bind="cell_1_3"></div>
						</div>
						<div class="tile tile-2 tile-position-1-4 tile-new">
							<div class="tile-inner" ng-bind="cell_1_4"></div>
						</div>
						<div class="tile tile-2 tile-position-2-1 tile-new">
							<div class="tile-inner" ng-bind="cell_2_1"></div>
						</div>
						<div class="tile tile-2 tile-position-2-2 tile-new">
							<div class="tile-inner" ng-bind="cell_2_2"></div>
						</div>
						<div class="tile tile-2 tile-position-2-3 tile-new">
							<div class="tile-inner" ng-bind="cell_2_3"></div>
						</div>
						<div class="tile tile-2 tile-position-2-4 tile-new">
							<div class="tile-inner" ng-bind="cell_2_4"></div>
						</div>
						<div class="tile tile-2 tile-position-3-1 tile-new">
							<div class="tile-inner" ng-bind="cell_3_1"></div>
						</div>
						<div class="tile tile-2 tile-position-3-2 tile-new">
							<div class="tile-inner" ng-bind="cell_3_2"></div>
						</div>
						<div class="tile tile-2 tile-position-3-3 tile-new">
							<div class="tile-inner" ng-bind="cell_3_3"></div>
						</div>
						<div class="tile tile-2 tile-position-3-4 tile-new">
							<div class="tile-inner" ng-bind="cell_3_4"></div>
						</div>
						<div class="tile tile-2 tile-position-4-1 tile-new">
							<div class="tile-inner" ng-bind="cell_4_1"></div>
						</div>
						<div class="tile tile-2 tile-position-4-2 tile-new">
							<div class="tile-inner" ng-bind="cell_4_2"></div>
						</div>
						<div class="tile tile-2 tile-position-4-3 tile-new">
							<div class="tile-inner" ng-bind="cell_4_3"></div>
						</div>
						<div class="tile tile-2 tile-position-4-4 tile-new">
							<div class="tile-inner" ng-bind="cell_4_4"></div>
						</div>
					</div>
				</div>
			</div>
			<p>How to play: Use your A,S,W,D keys to move the tiles or Z key to undo. When two tiles with the same number touch, they merge into one!</p>
				]"
		end

		login(nickname,password: STRING): BOOLEAN
				-- validate the user datas
				-- load the user from the file into the user variable, or void if the user doesn't exist
			require
				(create {USER_2048_UNDO}.make_empty).is_valid_nickname (nickname) and password /= Void
			local
				possible_user: USER_2048_UNDO
			do
				create possible_user.make_with_nickname (nickname)
				if possible_user.has_unfinished_game then
					possible_user.load_game
					if equal(password, possible_user.password) then
						user_log_in := possible_user
						Result:=True
					else
						Result:=False
					end
				else
					Result:=False
				end
			end

		add_user(nickname,password: STRING): BOOLEAN
		do
			Result:=True
		end

		load_board:STRING
		local
			js: STRING
			col,row: INTEGER
		do
			js:= "alert('pre LOAD BOARD'); try{ angular.module('myapp', []).controller('GameController',function ($scope){ "
			from
				col := 1
			until
				col > 4
			loop
				from
					row := 1
				until
					row > 4
				loop
					if( controller.board.elements.item (row, col).value /=0 )then
						js.append("$scope.cell_"+row.out+"_"+col.out+" = '"+controller.board.elements.item (row, col).value.out+"'")
					else
						js.append("$scope.cell_"+row.out+"_"+col.out+" = ''")
					end
					if not( row = 4 and col = 4) then
						js.append (" ; ")
					end
					row := row + 1
				end
				col := col + 1
			end
			js.append ("; alert('LOAD BOARD');});}catch(err){alert(err.message)}")
			Result := js
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
