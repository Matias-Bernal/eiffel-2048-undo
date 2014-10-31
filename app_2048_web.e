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

feature {NONE} -- Execution

	response (req: WSF_REQUEST): WSF_JSON_RESPONSE_MESSAGE
		-- Computed response message.
	do
		create Result.make
		if attached req.string_item ("login") as o_login then --SI SE LOGUEA
			if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
				if(login(nickname,password))then
					user_log_in.load_game
					if(user_log_in.has_unfinished_game)then
						controller := user_log_in.game
						Result.set_body ("{ %"status%": %"logged%" , %"board%": "+controller.board.to_json_array+" }")
					end
				else
					Result.set_body ("{ %"status%": %"error%" }")
				end
			end
		elseif attached req.string_item ("new_user")  as o_new_user then -- HACE UN USUARIO NUEVO
			if (attached req.string_item ("nickname") as nickname) and (attached req.string_item ("password") as password) then
				if(not login(nickname,password))then
					create user_log_in.make_new_user (nickname, password, controller)
					user_log_in.save_game (controller)
						Result.set_body ("{ %"status%": %"logged%" , %"board%": "+controller.board.to_json_array+" }")
				else
					Result.set_body ("{ %"status%": %"error%" }")
				end
			end
		elseif attached req.string_item ("game") as o_game then
			if(user_log_in /= Void) then
				if attached req.string_item ("new_game")  as o_new_user then
					create controller.make
					user_log_in.save_game (controller)
					Result.set_body ("{ %"status%": %"new_game%" , %"board%": "+controller.board.to_json_array+" }")
				elseif attached req.string_item ("save")  as o_new_user then
					user_log_in.save_game (controller)
					create controller.make
					user_log_in := Void
					Result.set_body ("{ %"status%": %"saved%" }")
				elseif attached req.string_item ("exit")  as o_new_user then
					Result.set_body ("{ %"status%": %"exit%" }")
					create controller.make
					user_log_in := Void
				elseif attached req.string_item ("move") as l_message then
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
						Result.set_body ("{ %"status%": %"win%" , %"board%": "+controller.board.to_json_array+" }")
					elseif not controller.board.can_move_up and not controller.board.can_move_down and not controller.board.can_move_left and not controller.board.can_move_right then
						Result.set_body ("{ %"status%": %"lose%" , %"board%": "+controller.board.to_json_array+" }")
					else
						Result.set_body ("{ %"status%": %"play%" , %"board%": "+controller.board.to_json_array+" }")
					end
				end
			else
				Result.set_body ("{ %"status%": %"error%" }")
			end
		end
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


feature {NONE} -- Initialization

	initialize
		do
				--| Uncomment the following line, to be able to load options from the file ewf.ini
			create {WSF_SERVICE_LAUNCHER_OPTIONS_FROM_INI} service_options.make_from_file ("ewf.ini")
			create controller.make
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
