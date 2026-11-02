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

#referencing board.gd's functions and variables
@onready var board = $board

func _ready() -> void:
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
	#gets the position of the where the mouse wants to place the piece
	var to_move = get_pos_under_mouse()
	
	#checks if the placement is valid compared to its original position
	if valid_move(selected_piece.global_board_position, to_move):
		#gets the piece that is at the coordinates player wants to drop the selected piece( returns null if there's no piece there) 
		var dest_piece = board.get_piece(to_move)
		
		#if there is a piece at the square and it is not the same color as the selected piece
		if dest_piece != null:
			#deletes the piece
			board.delete_piece(dest_piece)
		#moves the piece to the location
		selected_piece.move_position(to_move)
		
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

#checks if a piece has moved
func check_first_move(piece):
	return !piece.moved


func king_can_move_to(color, pos):
	var board_copy = board.clone()
	var king_copy = board_copy.get_piece(board_copy.kings[color])

	king_copy.move_position(pos)

	var threatened = false

	for piece in board_copy.pieces:
		if piece.color == color:
			continue

		if pos in piece.get_threatened_positions():
			threatened = true
			break

	board_copy.free()
	return !threatened

#castling 
#rules:
#king can't go in check/be already in check
#king can't have moved
#rook can't have moved
#nothing between rook and king

func castle(color, side):
	var king = board.get_piece(board.kings[color])

	if king == null:
		return false

	# King must not have moved or currently be in check
	if king.moved or check_king_threatened(color):
		return false

	# Find the correct rook
	var rank = 8 if color == Globals.COLORS.WHITE else 1
	var rook_file = 8 if side == "kingside" else 1
	var rook = board.get_piece(Vector2i(rook_file, rank))

	if rook == null:
		return false

	if rook.color != color or rook.piece_type != Globals.PIECE_TYPES.ROOK:
		return false

	if rook.moved:
		return false

	# Check that the spaces between king and rook are empty
	var direction = sign(rook.global_board_position.x - king.global_board_position.x)
	var x = king.global_board_position.x + direction

	while x != rook.global_board_position.x:
		if board.get_piece(Vector2i(x, king.global_board_position.y)) != null:
			return false
		x += direction

	# Check the squares the king travels through 
	var transit_x = king.global_board_position.x + direction
	var destination_x = king.global_board_position.x + (2 * direction)

	if !king_can_move_to(color, Vector2i(transit_x, rank)):
		return false

	if !king_can_move_to(color, Vector2i(destination_x, rank)):
		return false

	return true
