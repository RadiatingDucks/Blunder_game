extends Area2D

#Variable declarations
var color = Globals.COLORS.WHITE
var global_board_position: Vector2i
var moved = false
var piece_type: int
var board_handle

@export var piece_frame: int = 0:
	set(value):
		piece_frame = value
		if has_node("Sprite2D"):
			$Sprite2D.frame = piece_frame


func update_sprite():
	#gets the frame number from piece_type
	piece_frame = piece_type

func move_position(to_move:Vector2i):
	moved = true
	global_board_position = to_move
	position = Vector2(
		to_move.x * 16 + 8,
		to_move.y * 16 + 8
		)
		
	#checking where the king is
	if piece_type == Globals.PIECE_TYPES.KING:
		#registers the king
		board_handle.register_king(color, global_board_position)
	
	#pawn promotion
	if piece_type == Globals.PIECE_TYPES.PAWN and to_move.y == 1:
		#changing the piece type to queen
		piece_type = Globals.PIECE_TYPES.QUEEN
		#updates the sprite
		update_sprite()

func clone(_board):
	var piece = self.duplicate()
	piece.board_handle = _board
	return piece

func get_moveable_positions():
	match piece_type:
		Globals.PIECE_TYPES.PAWN: return pawn_threat_pos()
	
func get_threatened_positions():
	match piece_type:
		Globals.PIECE_TYPES.PAWN: return pawn_move_pos()
		

#pawn moves
const PAWN_SPOT_INCREMENT_MOVE = [[0,1]] #pawn moves one square forward
const PAWN_SPOT_INCREMENT_FIRST_MOVE = [[0,1], [0,2]]#pawn can move one or two squares forward on first move
const PAWN_SPOT_INCREMENTS_TAKE = [[-1,1], [1,1]]#pawn can capture pieces left or right

func pawn_threat_pos():
	var positions = []
	
	for inc in PAWN_SPOT_INCREMENTS_TAKE:
		var pos = board_handle.spot_search_threat(
			color,
			global_board_position[0], global_board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			true, false
		)
		if pos != null:
			positions.append(pos)

	return positions
	
func pawn_move_pos():
	var positions = []
		
	var increments = PAWN_SPOT_INCREMENT_MOVE if moved else PAWN_SPOT_INCREMENT_FIRST_MOVE
	for inc in increments:
		var pos = board_handle.spot_search_threat(
			color,
			global_board_position[0], global_board_position[1],
			inc[0], inc[1] if color == Globals.COLORS.BLACK else -inc[1],
			false, true
		)
		if pos != null:
			positions.append(pos)
		else:
			break
		
	return positions
	
