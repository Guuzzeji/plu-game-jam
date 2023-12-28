extends "res://componets/bullets/template/ammo.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimationPlayer.play("RESET")
	#$AnimationPlayer.play("init")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_pickup(body):
	print(body)
	pass # Replace with function body.
