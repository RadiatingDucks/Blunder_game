extends TileMap

#preloading chess pieces
const white_pieces = preload("res://scenes/whitePieces.tscn")
const black_pieces = preload("res://scenes/blackPieces.tscn")

@export var pieces =[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	#adds to game tree
	add_child(new_piece)
	
	pieces.append(new_piece)
	new_piece.global_board_position = grid_pos

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

func get_piece(pos: Vector2i):
	for piece in pieces:
		if piece.global_board_position == pos:
			return piece
