extends RayCast3D
####credit in main ai script
#### BASICALLY raycast hit something, update the target for the leg. (not ik one but child of raycast)
@export var step_target : Node3D		##the target_ik nodes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var hit_point = get_collision_point()
	if hit_point:
		step_target.global_position = hit_point
	pass

## dont forgedt to assign nodes!!
