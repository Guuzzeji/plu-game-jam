extends CharacterBody3D



var target = null ##the target the cube seeks
const SPEED = 3.0
var creator
@export var nav_agent: NavigationAgent3D ##so code can use navmesh.

### damage numbers
@onready var playerhud = load("res://componets/player/player_info.tres").Player_Hud

var health = 100.0 ##does what it says on tin
var inRange = false ##if player is in range, stop chasing. 

############### LEG VARIABLES #####################
@export var move_speed: float = 5.0
@export var turn_speed: float = 1.0
@export var ground_offset: float = 1.0

@onready var fl_leg = $targets/FL_Target_IK
@onready var fr_leg = $targets/FR_Target_IK
@onready var bl_leg = $targets/BL_Target_IK
@onready var br_leg = $targets/BR_Target_IK

func _ready():
	set_as_top_level(true) ####fixed a weird flippig issue
	
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
	
	leg_process(delta)	## code from the crawler example, all for the legs

############################ LEG FUNCTIONS ########################

func leg_process(delta):
	var plane1 = Plane(bl_leg.global_position, fl_leg.global_position, fr_leg.global_position)
	var plane2 = Plane(fr_leg.global_position, br_leg.global_position, bl_leg.global_position)
	var avg_normal = ((plane1.normal + plane2.normal) / 2).normalized()
	
	var target_basis = _basis_from_normal(avg_normal * -1)	##update basis (position and orentation in 3d space)
	## all code from video EXECPT the -1! This fixed it and I have NO idea why.
	## some reason the plane tool was genearting upside down planes?
	transform.basis = lerp(transform.basis, target_basis, move_speed * delta).orthonormalized()
	## lerp for smoothness according to video
	
	##code for main body ground offset or "height"
	var avg = (fl_leg.position + fr_leg.position + bl_leg.position + br_leg.position) / 4	###avg height where feet are at
	var target_pos = avg + transform.basis.y * ground_offset
	var distance = transform.basis.y.dot(target_pos - position)
	position = lerp(position, position + transform.basis.y * distance, move_speed * delta)
	
	##_handle_movement(delta)	## SHOULD NOT DO ANYTHING, REPLACE WITH PATHFINDING
	pass




func _handle_movement(delta):
	var direction = Input.get_axis('ui_down', 'ui_up')			##control direction we aremoving in (axis/vectofr 3?)
	translate(Vector3(0, 0, -direction) * move_speed * delta)
	
	var a_direction = Input.get_axis('ui_right', 'ui_left')		##another axis, but for  rotating around?
	rotate_object_local(Vector3.UP, a_direction * turn_speed * delta)		##local is so we can be on walls and such


#### cant explain how works,
##purpose : make crawler always face awayy from any surface, reguardless direction

func _basis_from_normal(normal: Vector3) -> Basis:	# I..wa.. just watch video 
	var result = Basis()
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)
	
	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z
	
	return result
	
