extends Area2D

var color = Globals.COLORS.WHITE
var global_board_position: Vector2i
var moved = false

@export var piece_frame: int = 0:
	set(value):
		piece_frame = value
		if has_node("Sprite2D"):
			$Sprite2D.frame = piece_frame
	


func move_position(to_move:Vector2i):
	moved = true
	global_board_position = to_move
	position = Vector2(
		to_move.x * 16 + 8,
		to_move.y * 16 + 8
		)
