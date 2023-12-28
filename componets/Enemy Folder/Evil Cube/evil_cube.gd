extends CharacterBody3D
## credit to https://www.youtube.com/watch?v=iV710Vm5qm0 for code base

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null ##the target the cube seeks
const SPEED = 3.0
var player_path := "../../../Player" ##OK WHY DOES THIS WORK # NodePath# "/res://componets/player/player.tscn"
@onready var nav_agent = $NavigationAgent3D ##so code can use navmesh.

var health = 100.0 ##does what it says on tin

func _ready():
	#print(player_path)
	#print(get_node("../../../Player"))
	#print(get_node(player_path))
	target = get_node(player_path) ##depeding on where in tree, returns null???

func _physics_process(delta):
	healthCheck()
	velocity = Vector3.ZERO #reset the velocity each loop
	nav_agent.set_target_position(target.global_position) #why
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED ##set speed and direction to next point
	
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	
	move_and_slide()

func inflictDamage(damage): #entities that damage use this
	health = health - damage

func healthCheck(): ##kill sentry if health drops below zero
	if health <= 0:
		#print ("goodby world")
		queue_free() #delete self, litterally 
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
