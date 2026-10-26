extends Node2D

#variable declarations
var player_color;
var status;
var player_2_type;

#To drag piece
var is_dragging: bool;
var selected_piece = null;
var previous_position = null;

@onready var board = $board

func _ready() -> void:
	start_game()
	
func _input(event):
	#when mouse clicks/drags
	if Input.is_action_just_pressed("left_click"):
		var pos = get_pos_under_mouse()
		selected_piece = board.get_piece(pos)
		#drag piece only if they are under mouse or right color
		if selected_piece == null or selected_piece.color != status:
			return
		is_dragging = true
		previous_position = selected_piece.position
		selected_piece.z_index = 100
	elif event is InputEventMouseMotion and is_dragging:
		selected_piece.global_position = get_global_mouse_position()
	elif Input.is_action_just_released("left_click") and is_dragging:
		
		#checks if the player made a valid move
		var is_valid_move = drop_piece()
		#if release position is illegal
		if !is_valid_move:
			#move piec back to its previous position
			selected_piece.position = previous_position
		selected_piece.z_index = 1
		selected_piece = null
		is_dragging = false
		

func start_game():
	is_dragging = false
	player_color = Globals.COLORS.WHITE
	status = Globals.COLORS.WHITE
	player_2_type = Globals.PLAYER_TWO_TYPE.HUMAN
	
func get_pos_under_mouse():
	var pos = get_global_mouse_position()
	pos.x = int(pos.x / 64)
	pos.y = int(pos.y / 64)
	return pos
	
func drop_piece():
	#gets the position of the where the mouse wants to place the piece
	var to_move = get_pos_under_mouse()
	
	#checks if the placement is valid compared to its original position
	if valid_move(selected_piece.global_board_position, to_move):
		#gets the piece that is at the coordinates player wants to drop the selected piece( returns null if there's no piece there) 
		var dest_piece = board.get_piece(to_move)
		
		#if there is a piece at the square and it is not the same color as the selected piece
		if dest_piece != null and dest_piece.color != selected_piece.color:
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
	
	return false

func valid_move(from_pos, to_pos):
	var board_copy = board.clone()
	var src_piece = board_copy.get_piece(from_pos)
	
	#if unable to move to movable or threatened position
	if(
		to_pos not in src_piece.get_moveable_positions()
		and 
		to_pos not in src_piece.get_moveable_posititons()
	):
		return false
	
	var dst_piece = board_copy.get_piece(to_pos)
	if dst_piece != null:
		board_copy.delete_piece(dst_piece)
	src_piece.move_position(to_pos)
	
	for piece in board_copy.pieces:
		if status == Globals.COLORS.BLACK and board_copy.black_king_pos in piece.get_threatened_positions():
			return false
		if status == Globals.COLORS.WHITE and board_copy.white_king_pos in piece.get_threatened_positions():
			return false
	return true
	
