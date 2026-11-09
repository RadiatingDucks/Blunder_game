extends Node2D

var last_move_from = Vector2i(-1, -1)
var last_move_to = Vector2i(-1, -1)

func _draw():
	var highlight_colour = Color(1, 0.85, 0.2, 0.4)

	#highlight the square the piece moved from
	if last_move_from != Vector2i(-1, -1):
		draw_rect(
			Rect2(
				Vector2(last_move_from.x * 16, last_move_from.y * 16),
				Vector2(16, 16)
			),
			highlight_colour
		)

	#highlight the square the piece moved to
	if last_move_to != Vector2i(-1, -1):
		draw_rect(
			Rect2(
				Vector2(last_move_to.x * 16, last_move_to.y * 16),
				Vector2(16, 16)
			),
			highlight_colour
		)


func set_last_move_highlight(from_pos: Vector2i, to_pos: Vector2i):
	last_move_from = from_pos
	last_move_to = to_pos
	queue_redraw()
