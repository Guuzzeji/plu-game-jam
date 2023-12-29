extends Area3D

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data

var orginator = Node3D
signal hit_body(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true) # Sets node to the view top of level tree
	$Life_Timer.start(Bullet_Info.Life_Time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	position += -global_transform.basis.z * Bullet_Info.Speed * delta
	pass

# Use when ever enemy node goes into body
func _on_body_entered(body):
	#print(self.get_parent().get_parent().get_parent(), " ", body)
	#print(body.get_node(self.get_parent().get_path()).exists())
	#print(orginator, " ", body)
	if (orginator == body):	##if body collided is the one that spawned bullet, dont collide
		#print("hit self")
		pass
	elif (body.is_in_group("Enemy")):
		print(body.get_groups(), "hit enemy")
		print("parents: ",body, " ", self.get_parent() )
		queue_free()
		body.inflictDamage(Bullet_Info.Damage)
	else:
		queue_free()
	#elif (!body.is_in_group("player")):
		#queue_free()
		#hit_body.emit(body)
		#print(body.get_groups())
	
		
		
	pass

func _on_life_timer_timeout():
	queue_free()
	pass # Replace with function body.
