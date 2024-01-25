extends Area3D

# **How to use**
# Create a new node .tscn file and have the root node be a Area3d node
# Then attach this script onto the Area3d node you create for the scene
# Also create a Timer parent node with the scene you created, will have to attach that in properties menu under Life Timer
# After that add a collision shape and fill out the properties in the editor

# Notes:
# - If you are getting error: "E 0:00:00:0655   projectile.gd:15 @ _ready(): Signal 'timeout' is already connected to given callable 'Area3D(projectile.gd)::_on_life_timer_timeout' in that object."
#		Just ignore it for now, Will fix later and isn't causing any bugs as of now 

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data
@export var Life_Timer : Timer

# **About**
# variable to stre what fired the projectile
# stops shooter from hitting self, requires projectile.orginator = self inside shooter code
# Also should add the curret character's speed to the bullet speed
var orginator = Node3D
#var playerSpeed = 

# **About**
# Signal for when bullet hits something 
# returns the body of what it hits
signal hit_body(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(Player_Info.Pbody," ", orginator)
	set_as_top_level(true) # Sets node to root level of the node tree (basically at sets parent to level/world node)
	Life_Timer.timeout.connect(_on_life_timer_timeout) # Connecting singal (time out) to func
	Life_Timer.one_shot = true
	Life_Timer.start(Bullet_Info.Life_Time)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update bullet to fly through world at speed define in bullet_info
	# Note: global_transform.basis.z gives us the front and back of a node and its rolation / scale, docs explain in more detail
	position += -global_transform.basis.z * Bullet_Info.Speed * delta
	pass

# **About**
# Use when ever enemy node goes into body
func _on_body_entered(body):
	#print(orginator)
	#print(body)
	print(body.owner)
	if (orginator == body):
		pass ##dont hit self
	elif (body.is_in_group("Enemy")):
		damage(body)
	elif body.is_in_group("player") && Bullet_Info.Enemy_Bullet:
		damage(body)
	else:	## hits something not self
		queue_free()
	pass

func damage(body):		##if an enemy (say evil rock) cannot be damaged, best not crash!
	#print(Bullet_Info.Damage)
	if body.has_method("inflictDamage"):	##if can inflict damage, damage it
		body.inflictDamage(Bullet_Info.Damage)
	queue_free()
	
# == Signal Code == 

# **About**
# Kill bullet after timer reaches zero / times up
func _on_life_timer_timeout():
	queue_free()
	pass
