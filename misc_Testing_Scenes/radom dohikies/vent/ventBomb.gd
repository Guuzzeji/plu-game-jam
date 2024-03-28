extends RigidBody3D

#var direction = -global_transform.basis.z ##initial direction #wARNING, DOES NOTHING SINCE NOT INITALIZED#
var forceApplied = 5
var lifetime = 4
var orginator = Node3D #body that fired this projectile
var safetyTime = .1
#var directionForce = direction * forceApplied ##a vector that points in the direction and which magnitude is the force applied.
## for example: directionForce.normalize() would return direction
func _ready():
	set_as_top_level(true) # Sets node to the view top of level tree
	#direction = position + -global_transform.basis.z 
	#directionForce = direction * forceApplied
	self.apply_central_impulse(-global_transform.basis.z * forceApplied )
	#Vector3.bounce(Vector3(1,0,0))
	$lifeTimer.start(lifetime)
	$SafetyFuze.start(safetyTime)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move_and_collide(direction*delta)
	pass


func _on_life_timer_timeout():
	detonate()
	
	pass # Replace with function body.


func _on_body_entered(body):
	if (orginator == body):	##if body collided is the one that spawned bullet, dont collide
		#print("hit self")
		pass
	elif (body.is_in_group("Enemy")):
		detonate()
		#print(body.get_groups(), "hit enemy")
		#print("parents: ",body, " ", self.get_parent() )
		
	elif (body.is_in_group("player")):
		detonate()
		#print(body.get_groups(), "hit enemy")
		#print("parents: ",body, " ", self.get_parent() )
		
		#body.inflictDamage(10)
	else:
		#print (body)
		pass
	pass # Replace with function body.

func detonate():	## bounce off target then explode
	$detonateTimer.start(.1)

func _on_detonate_timer_timeout():	##to explode, allow area to see target
	$explosionArea.monitoring = true

func _on_safety_fuze_timeout():
	self.set_contact_monitor(true)
	pass # Replace with function body.

func _on_explosion_area_body_entered(body):
	if body.has_method("inflictDamage"):
		body.inflictDamage(100)
	#else ##ony happens if missfire or body escaped blast radius before area detection activated
	queue_free()
	pass # Replace with function body.
