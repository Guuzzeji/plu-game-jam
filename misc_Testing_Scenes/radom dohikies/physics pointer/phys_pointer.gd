extends RigidBody3D

#######this code does not work correctly
# Called when the node enters the scene tree for the first time.
var targetPlayer
func _ready():
	#targetPlayer = get_node(player_path)
	var targetPlayerGroup = get_tree().get_nodes_in_group("player")
	for telepad in targetPlayerGroup:
		targetPlayer = telepad
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func look_follow(state, current_transform, target_position):
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = current_transform.basis*(Vector3(0, 0, 1))
	var target_dir = (target_position - current_transform.origin).normalized()
	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)

	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func _integrate_forces(state):
	var target_position = targetPlayer.get_global_transform().origin
	##target_position = to_local(target_position)
	look_follow(state, get_global_transform(), target_position)
