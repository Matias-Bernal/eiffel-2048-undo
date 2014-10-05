note
	description: "Summary description for {CONNECTION_SETUP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_SETUP

create
	make

feature -- Access

	database_appl: DATABASE_APPL [DATABASE]

feature {NONE} -- Initialization

	make
			-- Set up the repository.
		do

			create database_appl.login (a_name, a_psswd)
            database_appl.set_base

				-- Feel free to change the login credentials.
--			factory.set_database ("2048-undo")
--			factory.set_user ("root")
--			factory.set_password ("root")
--			repository := factory.new_repository
		end

end
