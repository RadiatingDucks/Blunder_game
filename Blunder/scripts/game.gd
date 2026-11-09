extends Node2D

#variable declarations

#what color is the player
var player_color;
#which color's turn is it
var status;
#whether the other player is ai or not
var player_2_type;

#To drag piece
var is_dragging: bool;
#stores the piece that user clicked on
var selected_piece = null;
#stores the poition the selected piece was in
var previous_position = null;

#last piece type moved
var last_move_piece = null
#last piece moved init pos
var last_move_from = Vector2i(-1, -1)
#last piece moved final pos
var last_move_to = Vector2i(-1, -1)

#referencing board.gd's functions and variables
@onready var board = $board

func _ready() -> void:
	board.game_controller = self
	start_game()

func _input(event):
	#when mouse left clicks
	if Input.is_action_just_pressed("left_click"):
		#stores mouse's position in pos
		var pos = get_pos_under_mouse()
		#finds the piece at that coordinate
		selected_piece = board.get_piece(pos)
		#drag piece only if they are under mouse or right color
		if selected_piece == null or selected_piece.color != status:
			return
		#switches the dragging variable state(bc player is dragging piece)
		is_dragging = true
		#set the current position of the piece to previous_position
		previous_position = selected_piece.position
		#renders above other pieces/the board with higher z_index
		selected_piece.z_index = 100
		
	#if the mouse is currently dragging the piece
	elif event is InputEventMouseMotion and is_dragging:
		#set the piece's position to the mouse's position(so it looks like it's following the mouse)
		selected_piece.global_position = get_global_mouse_position()
		
	#if the mouse released the chess piece
	elif Input.is_action_just_released("left_click") and is_dragging:
		
		#checks if the player made a valid move
		var is_valid_move = drop_piece()
		#if release position is illegal
		if is_valid_move:
			check_end_game(status)
		else:
			#move piec back to its previous position
			selected_piece.position = previous_position
		
		#reverts the piece's z index
		selected_piece.z_index = 1
		#resets the selected piece to nothing
		selected_piece = null
		#resets state of mouse
		is_dragging = false

#function to start the game(kinda like init which sets the variables and states)
func start_game():
	#resets
	is_dragging = false
	player_color = Globals.COLORS.WHITE
	status = Globals.COLORS.WHITE
	player_2_type = Globals.PLAYER_TWO_TYPE.HUMAN

#gets the coordinate of the mouse
func get_pos_under_mouse() -> Vector2i:
	#gets the global mouse position
	var pos = get_global_mouse_position()
	#converts it from pixel coordinates to integer coordinates used for the board
	return Vector2i(
		int(pos.x / 64),
		int(pos.y / 64)
	)


#function for checking if a piece can be placed and switches player
func drop_piece():
	var to_move = get_pos_under_mouse()

	# Store the original position before moving the piece
	var from_pos = selected_piece.global_board_position

	#check if the selected piece is a king
	if selected_piece.piece_type == Globals.PIECE_TYPES.KING:

		#check if king is moving two squares
		if abs(to_move.x - selected_piece.global_board_position.x) == 2:

			#check if castling kingside or queenside
			var side = "kingside" if to_move.x > selected_piece.global_board_position.x else "queenside"

			#check castling validity
			if castle(selected_piece.color, side):

				var rank = selected_piece.global_board_position.y
				var direction = 1 if side == "kingside" else -1

				#find rook
				var rook_file = 8 if side == "kingside" else 1
				var rook = board.get_piece(Vector2i(rook_file, rank))

				#move king
				selected_piece.move_position(to_move)

				#move rook
				rook.move_position(Vector2i(
					to_move.x - direction,
					rank
				))

				# Record the king's move
				# This also expires any previous en passant opportunity
				last_move_piece = selected_piece
				last_move_from = from_pos
				last_move_to = to_move
				
				# Update the yellow squares on the board
				board.set_last_move_highlight(from_pos, to_move)
				
				#switch turns
				status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE

				return true

			return false

	#normal movement

	#checks if the placement is valid compared to its original position
	if valid_move(from_pos, to_move):

		#check if is an en passant capture
		var is_en_passant = (
			selected_piece.piece_type == Globals.PIECE_TYPES.PAWN
			and board.get_piece(to_move) == null
			and abs(to_move.x - from_pos.x) == 1
			and can_en_passant(selected_piece, to_move)
		)

		#if this is an en passant capture
		if is_en_passant:
			#delete the opponent's pawn from its actual position
			var victim = board.get_piece(last_move_to)
			board.delete_piece(victim)

		#gets the piece that is at the coordinates player wants to drop the selected piece
		#returns null if there's no piece there
		var dest_piece = board.get_piece(to_move)

		#if there is a piece at the square and it is not the same color as the selected piece
		if dest_piece != null:
			#deletes the piece
			board.delete_piece(dest_piece)

		#moves the piece to the location
		selected_piece.move_position(to_move)

		# Record the move for checking future en passant opportunities
		last_move_piece = selected_piece
		last_move_from = from_pos
		last_move_to = to_move
		
		# Update the yellow squares on the board
		board.set_last_move_highlight(from_pos, to_move)
		
		#switches turns for black and white by detecting current color
		if status == Globals.COLORS.WHITE:
			status = Globals.COLORS.BLACK
		else:
			status = Globals.COLORS.WHITE

		return true

	#the move is not valid
	return false

#checks if a move is valid(inputs are the initial posiiton and destination
func valid_move(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	#makes a copy of the board
	var board_copy = board.clone()
	#finds piece at the initial position
	var src_piece = board_copy.get_piece(from_pos)
	
	#if there's no  piece at the inital poition
	if src_piece == null:
		#delete board clone
		board_copy.free()
		#move is not valid
		return false

	#if destinaton is not in the source piece's moveable position list
	if to_pos not in src_piece.get_moveable_positions():
		#delete the board clone
		board_copy.free()
		#move is not valid
		return false
	
	#gets the piece at the destination from the board clone
	var dst_piece = board_copy.get_piece(to_pos)
	
	#if there is a piece at destination 
	if dst_piece != null:
		#if the piece at destination is same color as the piece being moved
		if dst_piece.color == src_piece.color:
			#delete the board clone
			board_copy.free()
			#move is not valid
			return false
		#if the color is different delete the piece at destination 
		board_copy.delete_piece(dst_piece)
	
	#moves source piece to destination
	src_piece.move_position(to_pos)
	
	#finds the source piece color's king from board clone
	var own_king_pos = board_copy.kings[src_piece.color]
	#new variable for state of king(in check or not)
	var is_king_threatened = false
	
	#check if king is in check
	for piece in board_copy.pieces:
		#skips pieces that are the same color as the king
		if piece.color == src_piece.color:
			continue
		
		#if the king is in a place that the opponent piece can move to
		if own_king_pos in piece.get_threatened_positions():
			#switches king's in check state to be true
			is_king_threatened = true
			break
	#deletes board
	board_copy.free()
	return not is_king_threatened

#checks valid moves of each piece
func check_valid_move(color):
	#for every piece on the board
	for piece in board.pieces:
		#if the piece is the color wanted
		if piece.color == color:
			#from all the positions the piece can move to
			for pos in piece.get_moveable_positions():
				#checks if move is valid
				if valid_move(piece.global_board_position, pos):
					#return true if move is valid
					return true
	return false

#checks if king is in check
func check_king_threatened(color) -> bool:
	#for every piece on the board
	for piece in board.pieces:
		#skips pieces that are the same color as the king
		if piece.color == color:
			continue
		
		#if the king is in a place that the opponent piece can move to
		if board.kings[color] in piece.get_threatened_positions():
			#return true
			return true
	return false

#check if checkmate
func check_end_game(color) -> bool:
	#if king is in check and there are no valid moves
	if check_valid_move(color) == false:
		if check_king_threatened(color):
			print("Checkmate!!!")
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
			#return checkmate is true
			return true
		print("Stalemate D:")
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		return true
	return false

#checks if king can move to a position legally
func king_can_move_to(color, pos):
	#creates copy of board
	var board_copy = board.clone()
	#finds the king required
	var king_copy = board_copy.get_piece(board_copy.kings[color])
	
	#let the king move to the position
	king_copy.move_position(pos)
	
	#threatened state variable
	var threatened = false
	
	#checks if pieces are the right colour
	for piece in board_copy.pieces:
		if piece.color == color:
			continue
		
		#checks if the position is in the list of positions this piece can move to
		if pos in piece.get_threatened_positions():
			#switch state to threatened
			threatened = true
			break
	#delete board clone
	board_copy.free()
	#return state of king at position
	return !threatened

#castling 
#rules:
#king can't go in check/be already in check
#king can't have moved
#rook can't have moved
#nothing between rook and king

func castle(color, side):
	var king = board.get_piece(board.kings[color])
	
	#checks if there is a king
	if king == null:
		return false

	# checks if king has moves or is in check
	if king.moved or check_king_threatened(color):
		return false

	# Find the correct rook
	#finding row required based on color
	var rank = 8 if color == Globals.COLORS.WHITE else 1 
	#finding if castling left or right
	var rook_file = 8 if side == "kingside" else 1 
	#get the rook required for castling
	var rook = board.get_piece(Vector2i(rook_file, rank))
	
	#check if king still at original postion
	if king.global_board_position != Vector2i(5, rank):
		return false
	
	#check if rook exsits
	if rook == null:
		return false
	
	#check if rook is of same colour and a rook
	if rook.color != color or rook.piece_type != Globals.PIECE_TYPES.ROOK:
		return false

	#check if rook has moved
	if rook.moved:
		return false

	# check that the spaces between king and rook are empty
	#finds the direction the king is castling mathematically(1 or -1)
	var direction = sign(rook.global_board_position.x - king.global_board_position.x)
	var x = king.global_board_position.x + direction
	
	#checks each square between king and rook
	while x != rook.global_board_position.x:
		#checks if there's a piece in between king and rook
		if board.get_piece(Vector2i(x, king.global_board_position.y)) != null:
			return false
		#check the next square over
		x += direction

	# Check the squares the king travels through 
	var init_x = king.global_board_position.x + direction
	var destination_x = king.global_board_position.x + (2 * direction)
	
	#checks if no threats from other pieces
	if !king_can_move_to(color, Vector2i(init_x, rank)):
		return false
	#checks if no threats
	if !king_can_move_to(color, Vector2i(destination_x, rank)):
		return false
	return true

#En passant
#rules
#1. pawn must be at the 5th/4th rank
#2. ooponent's pawn must move two squares
#3. the opponent's pawn must reach adjacent square of the pawn by  first move
func can_en_passant(pawn, target_pos):
	#previous move must have been made by a pawn
	if last_move_piece == null:
		return false

	if last_move_piece.piece_type != Globals.PIECE_TYPES.PAWN:
		return false

	#previous pawn must belong to the opponent
	if last_move_piece.color == pawn.color:
		return false

	#opponent's pawn must have moved two squares
	if abs(last_move_to.y - last_move_from.y) != 2:
		return false

	#opponent's pawn must be adjacent
	if last_move_to.y != pawn.global_board_position.y:
		return false

	if abs(last_move_to.x - pawn.global_board_position.x) != 1:
		return false

	#target must be the square directly behind the opponent's pawn
	var direction = -1 if pawn.color == Globals.COLORS.WHITE else 1

	if target_pos != last_move_to + Vector2i(0, direction):
		return false

	return true
