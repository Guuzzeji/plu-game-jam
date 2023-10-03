extends Area3D

@export var Projectile: PackedScene
@export var Bullet_Info : Bullet_Type

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("init")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Use when ever enemy node goes into body
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("hit")
		body.Left_Barrel = Projectile
		body.Right_Barrel = Projectile
		queue_free()
	pass
