extends Area3D

@export var Bullet_Info : Bullet_Type

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true) # Sets node to the view top of level tree
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	position += -global_transform.basis.z * Bullet_Info.Speed * delta
	pass

# Use when ever enemy node goes into body
func _on_body_entered(body):
	queue_free()
	pass
