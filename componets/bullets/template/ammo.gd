extends Area3D

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data

signal player_pickup(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Bullet_Info.Projectile)
	pass

# Use when ever enemy node goes into body
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("hit")
		player_pickup.emit(body)
		Player_Info.Bullet_Inventory.push_front(Bullet_Info)
		queue_free()
	pass
