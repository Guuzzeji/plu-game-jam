extends "res://componets/bullets/template/ammo.gd"

# **Overview**
# Example of how to connect and setup bullet template for use in game

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("init")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# == Signal Code ==

# **About**
# Signal for when player pick up code
# Used for debugging
func _on_player_pickup(body):
	print(body)
	pass # Replace with function body.
