extends Area2D

@export var piece_frame: int = 0:
	set(value):
		piece_frame = value
		if has_node("Sprite2D"):
			$Sprite2D.frame = piece_frame
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = piece_frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
