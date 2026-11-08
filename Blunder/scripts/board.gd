extends TileMap

#preloading chess pieces
const white_pieces = preload("res://scenes/whitePieces.tscn")
const black_pieces = preload("res://scenes/blackPieces.tscn")

#stores all chess pieces currently on board
@export var pieces =[]
#stores where the king is
var kings = {}

#reference to game node
var game_controller

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sets board
	reset_board()

#makes new pieces in positions wanted
func spawn_pieces(scene: PackedScene, grid_pos: Vector2i, frame_index: int) -> void:
	#creates a piece
	var new_piece = scene.instantiate()
	
	#position of the piece
	new_piece.position = Vector2(
	grid_pos.x * 16 + 8,
	grid_pos.y * 16 + 8
	)
	
	#gets sprite key frame from variable
	
	new_piece.piece_frame = frame_index
	new_piece.piece_type = frame_index
	new_piece.board_handle = self
	new_piece.global_board_position = grid_pos
	
	#checks if new piece is king and stores pos in dictionary
	if new_piece.piece_type == Globals.PIECE_TYPES.KING:
		register_king( new_piece.color, new_piece.global_board_position)
	
	#adds to game tree
	add_child(new_piece)
	
	#add to piece array
	pieces.append(new_piece)

#resets board back to initial position
func reset_board() -> void:
	#white side
	spawn_pieces(white_pieces, Vector2(1,8), 2) # Rook A1
	spawn_pieces(white_pieces, Vector2(8,8), 2) #Rook H1
	spawn_pieces(white_pieces, Vector2(2,8), 1) #Knight B1
	spawn_pieces(white_pieces, Vector2(7,8), 1) #Knight G1
	spawn_pieces(white_pieces, Vector2(3,8), 3) #Bishop C1
	spawn_pieces(white_pieces, Vector2(6,8), 3) #Bishop F1
	spawn_pieces(white_pieces, Vector2(4,8), 4) #Queen D1
	spawn_pieces(white_pieces, Vector2(5,8), 5) #King E1
	
	spawn_pieces(white_pieces, Vector2(1,7), 0) #Pawn A2
	spawn_pieces(white_pieces, Vector2(2,7), 0) #Pawn B2
	spawn_pieces(white_pieces, Vector2(3,7), 0) #Pawn C2
	spawn_pieces(white_pieces, Vector2(4,7), 0) #Pawn D2
	spawn_pieces(white_pieces, Vector2(5,7), 0) #Pawn E2
	spawn_pieces(white_pieces, Vector2(6,7), 0) #Pawn F2
	spawn_pieces(white_pieces, Vector2(7,7), 0) #Pawn G2
	spawn_pieces(white_pieces, Vector2(8,7), 0) #Pawn H2
	
	#black side
	spawn_pieces(black_pieces, Vector2(1,1), 2) # Rook A8
	spawn_pieces(black_pieces, Vector2(8,1), 2) #Rook H8
	spawn_pieces(black_pieces, Vector2(2,1), 1) #Knight B8
	spawn_pieces(black_pieces, Vector2(7,1), 1) #Knight G8
	spawn_pieces(black_pieces, Vector2(3,1), 3) #Bishop C8
	spawn_pieces(black_pieces, Vector2(6,1), 3) #Bishop F8
	spawn_pieces(black_pieces, Vector2(4,1), 4) #Queen D8
	spawn_pieces(black_pieces, Vector2(5,1), 5) #King E8
	
	spawn_pieces(black_pieces, Vector2(1,2), 0) #Pawn A7
	spawn_pieces(black_pieces, Vector2(2,2), 0) #Pawn B7
	spawn_pieces(black_pieces, Vector2(3,2), 0) #Pawn C7
	spawn_pieces(black_pieces, Vector2(4,2), 0) #Pawn D7
	spawn_pieces(black_pieces, Vector2(5,2), 0) #Pawn E7
	spawn_pieces(black_pieces, Vector2(6,2), 0) #Pawn F7
	spawn_pieces(black_pieces, Vector2(7,2), 0) #Pawn G7
	spawn_pieces(black_pieces, Vector2(8,2), 0) #Pawn H7

#gets the piece from a given position
func get_piece(pos: Vector2i):
	#checks piece array
	for piece in pieces:
		if piece.global_board_position == pos:
			return piece

#deletes pieces
func delete_piece(piece):
	for i in range(len(pieces)):
		#checks if its the right piece
		if pieces[i] == piece:
			var popped = pieces.pop_at(i)
			#deletes piece
			popped.queue_free()
			return

#register king function for finding checks
func register_king(piece_color, board_position):
	kings[piece_color] = board_position


func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	var threat_pos = []

	# Move one square in the chosen direction
	cur_x += inc_x
	cur_y += inc_y
	
	#while the piece is still in board
	while cur_x >= 1 and cur_x < 9 and cur_y >= 1 and cur_y < 9:
		#current position variable
		var cur_pos = Vector2i(cur_x, cur_y)
		#finds if there's a piece there
		var cur_piece = get_piece(cur_pos)

		if cur_piece != null:
			# check if an enemy piece can be captured
			if cur_piece.color != own_color:
				threat_pos.append(cur_pos)

			# Stop when any piece blocks the path
			break

		# Add this empty square as a possible move
		threat_pos.append(cur_pos)

		# Continue one square further along the path
		cur_x += inc_x
		cur_y += inc_y

	return threat_pos


func spot_search_threat(
	own_color,
	cur_x, cur_y,
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	#do a single move and check if move is valid
	cur_x += inc_x
	cur_y += inc_y

	if cur_x < 1 or cur_x > 8 or cur_y < 1 or cur_y > 8:
		return

	var cur_pos = Vector2i(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	#if there's a piece at pos
	if cur_piece != null:
		if free_only:
			return
		#return pos if there's an enemy at pos else don't return pos
		return cur_pos if cur_piece.color != own_color else null

	return cur_pos


func clone():
	#creates duplicate of board
	var board = self.duplicate()
	#duplicate of kings pos dictionary
	board.kings = kings.duplicate()
	#copies reference to game node
	board.game_controller = game_controller
	
	#for each piece
	for i in range(len(pieces)):
		#clones pieces
		var piece = pieces[i].clone(board)
		#replaces in array
		board.pieces[i] = piece
	#return cloned board
	return board
