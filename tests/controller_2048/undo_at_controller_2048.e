note
	description: "Tests for 'undo' in CONTROLLER_2048."
	author: "Manefelice221187"
	date: "october 6, 2014"
	revision: "0.01"
	testing: "type/manual"

class
	UNDO_AT_CONTROLLER_2048

inherit
	EQA_TEST_SET

feature -- Test routines

	test_move_undo_at_controller_2048_with_moving_right
			-- New test routine
			-- Scenario: Moving RIGHT changes board state colapsing crashing cells with
			--                        similar values
			--                Given the game board is in state
			--                        |2 |2 |2 |4 |
			--                        |4 |  |4 |2 |
			--                        |2 |  |  |  |
			--                        |  |  |  |  |
			--                When I move RIGHT
			--                Then I should obtain
			--                        |  |2 |4 |4 |
			--                        |  |  |8 |2 |
			--                        |  |  |  |2 |
			--                        |  |  |  |  |
			--                And one of the empty cells remaining filled with 2 or 4.
			--
			--			 Aplicated UNDO, restores the previous state board.	
			--
			--						  |2 |2 |2 |4 |
			--                        |4 |  |4 |2 |
			--                        |2 |  |  |  |
			--                        |  |  |  |  |
		local
		board: BOARD_2048
		controller: CONTROLLER_2048
		do
			create board.make_empty
			create controller.make_with_board (board)
			controller.board.set_cell (1, 1, 2)
			controller.board.set_cell (1, 2, 2)
			controller.board.set_cell (1, 3, 2)
			controller.board.set_cell (1, 4, 4)
			controller.board.set_cell (2, 1, 4)
			controller.board.set_cell (2, 3, 4)
			controller.board.set_cell (2, 4, 2)
			controller.board.set_cell (3, 1, 2)
			controller.right
			assert ("First row moved right correctly", controller.board.elements.item (1, 2).value = 2 and controller.board.elements.item (1, 3).value = 4 and controller.board.elements.item (1, 4).value = 4)
			assert ("Second row moved right correctly", controller.board.elements.item (2, 3).value = 8 and controller.board.elements.item (2, 4).value = 2)
			assert ("Third row moved right correctly", controller.board.elements.item (3, 4).value = 2)
			controller.undo
			assert ("First row moved undo correctly", controller.board.elements.item (1, 1).value = 2 and controller.board.elements.item (1, 2).value = 2 and controller.board.elements.item (1, 3).value = 2 and controller.board.elements.item (1, 4).value = 4)
			assert ("Second row moved undo correctly", controller.board.elements.item (2, 1).value = 4 and controller.board.elements.item (2, 3).value = 4 and controller.board.elements.item (2, 4).value = 2)
			assert ("Third row moved undo correctly", controller.board.elements.item (3, 1).value = 2)
		end

	test_move_undo_when_have_not_moves_previous
			--New test routine
			-- Scenario:
			--                Given the game board is in state
			--                        |2 |  |  |  |
			--                        |  |  |  |  |
			--                        |  |  | 2|  |
			--                        |  |  |  |  |
			-- 				can not move undo, because have not history previously
		local
		board: BOARD_2048
		controller: CONTROLLER_2048
		failed, second_time: BOOLEAN
		do
			if not second_time then
				failed := True
				create board.make_empty
				create controller.make_with_board (board)
				controller.board.set_cell (1, 1, 2)
				controller.board.set_cell (3, 3, 2)
				controller.undo
				failed := False
			end
			assert ("can not aplicated move undo", failed)
			rescue
     			second_time := True
     			if failed then   -- failed = true means that the rutine failed
           			retry
    			end
		end



end


