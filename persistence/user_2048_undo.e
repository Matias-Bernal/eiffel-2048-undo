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
	make_new_user, make_existant_user

feature -- Status report

	id: INTEGER
		-- Identifier
	nickname: STRING
		-- name under which the file is stored persistent game
	password: STRING
		-- password of user
	game : CONTROLLER_2048
		-- saved game
	unfinished_game : BOOLEAN
		-- Returns true if the user has an unfinished game

feature -- Initialisation

	make_existant_user(existant_id:INTEGER; existant_nickname, existant_password: STRING; existant_game: CONTROLLER_2048; existant_unfinish_game: BOOLEAN)
		-- Create a new user with existant user status
	require
		is_valid_password(existant_password)
		is_valid_nickname(existant_nickname)
	do
		id:=existant_id
		nickname:=existant_nickname
		password:=existant_password
		game := existant_game
		unfinished_game:= existant_unfinish_game
	end


	make_new_user(new_id: INTEGER; new_nickname, new_password: STRING)
		-- Create a new user with all atributes
	require
		is_valid_password(new_password)
		is_valid_nickname(new_nickname)
	do
		id:=new_id
		nickname:=new_nickname
		password:=new_password
		unfinished_game:=true
		create game.make
	end


feature -- Status setting

	--Saves the state of the current game board corresponding to this user
	--Requires that "new_game" is not void.
	save_game (new_game: CONTROLLER_2048)
	require
		new_game /= Void
	do
		game := new_game
		--store_by_name(path_saved_games+nickname)
	ensure
		game = new_game
	end

	load_game
		-- Load a saved_game
--	require
--		existing_file(nickname)
	do
--		if attached {USER_2048_UNDO} retrieve_by_name(path_saved_games+nickname) as user_file then
--			name := user_file.name
--			surname := user_file.surname
--			password := user_file.password
--			game := user_file.game
--		end
	ensure
		(password /= Void) and (game /= Void)
	end

	set_existant_unfinish_game(new_existant_unfinish_game: BOOLEAN)
	do
		unfinished_game:= new_existant_unfinish_game
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
