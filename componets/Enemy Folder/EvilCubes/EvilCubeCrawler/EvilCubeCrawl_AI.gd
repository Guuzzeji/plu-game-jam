extends Node3D

############################ code from https://www.youtube.com/watch?v=G_seJ2Yg1GA
## well you know the drill by now, from -> turning into -> based on

## steps so far
# 1. import skele and model
# 2. add skeletonik3d nodes for each leg, choose for root the start or "thigh" of leg, then choose the ONE BEFORE? the last bone of leg
			#reason: choose last bone, get weird error where leg locks to one bone, apparently blender issue?
# 3. add this code bselow
# 4. add 4 target nodes, add to bone things, can switch steps 3 and 4
# 5. add Step_Target_Container Node3D node to root node
# 6. make sure ik target marker nodes are  on top level. It is a tick box in transform
# 7. add raycasts  positioned on top of each ik target but under the container, move them up as seen,
# 8. add a NEW target marker in the exact same spot as the previious ones BUT as children of the raycasts
# 8. attach iktarget script with step code

@export var move_speed: float = 5.0
@export var turn_speed: float = 1.0
@export var ground_offset: float = 1.0

@onready var fl_leg = $FL_Target_IK
@onready var fr_leg = $FR_Target_IK
@onready var bl_leg = $BL_Target_IK
@onready var br_leg = $BR_Target_IK


func _ready():
	set_as_top_level(true) ####fixed a weird flippig issue

func _process(delta):
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
	
	_handle_movement(delta)
	
	




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
	
