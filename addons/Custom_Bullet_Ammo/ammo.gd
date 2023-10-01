extends Area3D

@export var Bullet_Info: Bullet_Type

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Use when ever enemy node goes into body
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("hit")
		body.Left_Barrel = Bullet_Info.Projectile_Scene
		body.Right_Barrel = Bullet_Info.Projectile_Scene
		queue_free()
	pass
