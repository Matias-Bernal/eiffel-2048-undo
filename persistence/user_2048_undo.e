note
	description: "Summary description for {USER_2048_undo}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER_2048_UNDO
inherit
	STORABLE

create
	make_empty, make_new_user, make_existant_user,make_with_nickname,make_with_nick_and_pass

feature -- Status report

	nickname: STRING
		-- name under which the file is stored persistent game
	password: STRING
		-- password of user
	game : CONTROLLER_2048
		-- saved game

	path_saved_games : STRING
            -- Returns the path to the folder containing saved games
        once
            Result := ".saved_games/"
        end

	has_unfinished_game : BOOLEAN
		-- Returns true if the user has an unfinished game	
	require
		valid_nickname: is_valid_nickname(nickname)
	local
		file : RAW_FILE
	do
		create file.make_with_name (path_saved_games+nickname)
			if file.exists and then file.is_readable then
				Result := True
			end
	end

	existing_file(nickname_control: STRING): BOOLEAN
		-- Check if file exists
	do
		if attached retrieve_by_name(path_saved_games+nickname_control) as file then
			Result := True
		else
			Result := False
		end
	end

feature -- Initialisation

	make_empty
	do
	end

	make_existant_user(existant_nickname, existant_password: STRING; existant_game: CONTROLLER_2048)
		-- Create a new user with existant user status
	require
		is_valid_password(existant_password)
		is_valid_nickname(existant_nickname)
	do
		nickname:=existant_nickname
		password:=existant_password
		game := existant_game
	end


	make_new_user(new_nickname, new_password: STRING;existant_game: CONTROLLER_2048;)
		-- Create a new user with all atributes
	require
		is_valid_password(new_password)
		is_valid_nickname(new_nickname)
	do
		nickname:=new_nickname
		password:=new_password
		game := existant_game
	end

	make_with_nickname(nick: STRING)
		-- Create a new user with nickname atribute
	require
		is_valid_nickname(nick)
	do
		nickname:=nick
	end


	make_with_nick_and_pass(nick, pass: STRING)
		-- Create a new user with nickname and password atribute
	require
		is_valid_password(pass)
		is_valid_nickname(nick)
	do
		nickname:=nick
		password:=pass
	end

feature -- Status setting

	--Saves the state of the current game board corresponding to this user
	--Requires that "new_game" is not void.
	save_game (new_game: CONTROLLER_2048)
	require
		new_game /= Void
	do
		game := new_game
		store_by_name(path_saved_games+nickname)
	ensure
		game = new_game
	end

	load_game
		-- Load a saved_game
	require
		existing_file(nickname)
	do
		if attached {USER_2048_UNDO} retrieve_by_name(path_saved_games+nickname) as user_file then
			nickname := user_file.nickname
			password := user_file.password
			game := user_file.game
		end
	ensure
		(password /= Void) and (game /= Void)
	end

feature -- Control methods

	is_valid_password(pass_control: STRING): BOOLEAN
		-- Validate if pass isnt void or empty
	require
		password /= Void
	do
		Result:=(pass_control /= Void) and (not pass_control.is_equal (""))
	end

	is_valid_nickname(nickname_control: STRING): BOOLEAN
	require
		nickname /= Void
	do
		Result:= not nickname_control.is_empty
	end

end
