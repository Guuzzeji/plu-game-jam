extends CharacterBody3D



var target = null ##the target the cube seeks
const SPEED = 3.0
var creator
@export var nav_agent: NavigationAgent3D ##so code can use navmesh.

### damage numbers
@onready var playerhud = load("res://componets/player/player_info.tres").Player_Hud

var health = 100.0 ##does what it says on tin
var inRange = false ##if player is in range, stop chasing. This is 

func _ready():
	# to not wait during set up, code from example in godot documentation
	target = load("res://componets/player/player_info.tres").Pbody
	call_deferred("actor_setup")
	

func actor_setup():
	await get_tree().physics_frame
	set_movement_target(target.global_position)
	# wait for nav map to sync, should prevent red error the previous cubes had

func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		#print("finished?")
		set_movement_target(target.global_position)
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * SPEED
	move_and_slide()
	
	pass
