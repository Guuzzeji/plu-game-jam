extends Node3D

var activated = false
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.

func _on_area_3d_body_entered(body):
	if body.is_in_group(player):
		emit_signal("PlayerPadActivated")
	pass # Replace with function body.
