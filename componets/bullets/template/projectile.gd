extends Area3D

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data

# **About**
# Signal for when bullet hits something 
# returns the body of what it hits
signal hit_body(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true) # Sets node to the view top of level tree
	$Life_Timer.start(Bullet_Info.Life_Time)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update bullet to fly through world at speed define in bullet_info
	position += -global_transform.basis.z * Bullet_Info.Speed * delta
	pass

# **About**
# Use when ever enemy node goes into body
func _on_body_entered(body):
	if (!body.is_in_group("player")):
		queue_free()
		hit_body.emit(body)
		print(body.get_groups())
		hit_body.emit(body)
	pass


# == Signal Code == 

# **About**
# Kill bullet after timer reaches zero / times up
func _on_life_timer_timeout():
	queue_free()
	pass
