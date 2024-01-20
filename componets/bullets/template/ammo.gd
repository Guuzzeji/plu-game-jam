extends Area3D

# **How to use**
# Create a new node .tscn file and have the root node be a Area3d node
# Then attach this script onto the Area3d node you create for the scene
# After that add a collision shape and fill out the properties in the editor

# **Overview**
# Part of the bullet template, this is used for creating bullet item for 
# player to be able to pick up.
# Note: may have to create custom ammo if need more custom stuff

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data

# Note to use AnimationPlayer have to have to animations 
# - "RESET" = reset the node to a state to correctly play animation
# - "IDLE" = the animation you want to run
@export var AnimPlayer : AnimationPlayer

# **About**
# Signal for when player picks up bullet
signal player_pickup(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Doing this so we can run code without animations
	if AnimPlayer != null:
		AnimPlayer.play("RESET")
		AnimPlayer.play("IDLE")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(Bullet_Info.Projectile)
#	pass

# **About**
# Use when ever enemy node goes into body
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("ammo pickup hit")
		player_pickup.emit(body)
		#print(Bullet_Info)
		#print(Player_Info)
		Player_Info.Bullet_Inventory.push_front(Bullet_Info)
		queue_free()
	pass
