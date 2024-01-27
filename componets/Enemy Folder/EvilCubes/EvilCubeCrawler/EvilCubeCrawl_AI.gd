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

@onready var fl_leg = $FL_Target_IK
@onready var fr_leg = $FR_Target_IK
@onready var bl_leg = $BL_Target_IK
@onready var br_leg = $BR_Target_IK

func _process(delta):
	
	_handle_movement(delta)
	
	




func _handle_movement(delta):
	var direction = Input.get_axis('ui_down', 'ui_up')			##control direction we aremoving in (axis/vectofr 3?)
	translate(Vector3(0, 0, -direction) * move_speed * delta)
	
	var a_direction = Input.get_axis('ui_right', 'ui_left')		##another axis, but for  rotating around?
	rotate_object_local(Vector3.UP, a_direction * turn_speed * delta)		##local is so we can be on walls and such
	
	
