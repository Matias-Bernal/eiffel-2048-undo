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



feature {NONE} -- Execution

	response (req: WSF_REQUEST): WSF_HTML_PAGE_RESPONSE
			-- Computed response message.
		do
			create Result.make

			Result.add_javascript_url ("http://code.jquery.com/jquery-latest.min.js")
			Result.add_javascript_content ("function getChoice(keyCode){var ret='';if (keyCode == 119)ret = 'up';if (keyCode == 115)ret = 'down';if (keyCode == 100)ret = 'right';if (keyCode == 97)ret = 'left';if (keyCode == 122)ret = 'undo';return ret;}")
			Result.add_javascript_content ("$(document).keypress(function (e) {var key = getChoice(e.keyCode);if(key != ''){$.ajax({type : 'POST',url:'http://localhost:9999/',data:{message:key},contentType:'json',headers: {Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Content-Type': 'application/x-www-form-urlencoded'}}).done(function(data){document.open();document.write(data);document.close();})}})")

			if status = 0 then
				--Main Menu
				Result.set_title ("2048-UNDO / MAIN MENU")
				if(show_main_menu)then
					Result.set_body (print_html_main_menu)
				else
					if attached req.string_item ("option") as l_option then
						if l_option.is_equal ("login") then
							show_main_menu := False
							show_login:= True
							status := 1
						elseif l_option.is_equal ("new_user") then
							show_main_menu := False
							show_new_user:= True
							status := 2
						elseif l_option.is_equal ("play") then
							show_main_menu := False
							status := 3
						end
					end
				end

			elseif status = 1 then
				-- 1 : Login
				Result.set_title ("2048-UNDO / LOGIN")
				if(show_login)then
					Result.set_body (print_html_login)
				else
					if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
						if(login(nickname,password))then
						else
							Result.add_javascript_content ("alert('Nickname y/o Contraseña invalidos')")
						end
					end
				end

			elseif status = 2 then
				-- 2 : New User
				Result.set_title ("2048-UNDO / NEW USER")

				if(show_new_user)then
					Result.set_body (print_html_new_user)
				else
					if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
						if(add_user(nickname,password))then
						else
							Result.add_javascript_content ("alert('Nickname y/o Contraseña invalidos')")
						end
					end
				end

			elseif status = 3 then
				Result.set_title ("2048-UNDO")

				if(user_log_in /= Void) then -- The user is log in
					if attached req.string_item ("message") as l_message then
						if l_message.is_equal ("up") then -- Press button 'w'
							if controller.board.can_move_up then
								controller.up
							end
						elseif l_message.is_equal ("down") then -- Press button 's'
							if controller.board.can_move_down then
								controller.down
							end
						elseif l_message.is_equal ("left") then -- Press button 'a'
							if controller.board.can_move_left then
								controller.left
							end
						elseif l_message.is_equal ("right") then -- Press button 'd'
							if controller.board.can_move_right then
								controller.right
							end
						elseif l_message.is_equal ("undo") then -- Press button 'z'
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
						Result.set_body (print_html_board)
					end
				else
					Result.add_javascript_content ("alert('Debe loguearse o crear un nuevo usuario')")
					show_main_menu:=True
				end
			end
		end

		print_html_main_menu: STRING
		do
			Result:="menu"
		end

		print_html_login: STRING
		do
			Result:="login"
		end

		print_html_new_user: STRING
		do
			Result:="new user"
		end

		print_html_board: STRING
		do
			Result:=controller.board.out
		end


		login(nickname,password: STRING): BOOLEAN
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
			--status := 3
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
