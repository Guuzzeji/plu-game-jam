extends Marker3D

###credit goes to link in evilcubecrawl_AI

@export var step_target : Node3D ## ex: FR_Target
@export var step_distance : float = 3.0

@export var adjacent_leg : Node3D ## "partner" leg, so these two dont step in sync, you left steps while right stays
@export var opposite_leg : Node3D ## thing hind and diag front step in sinc, so diagnal legs are synced when moving in diagnal

var is_stepping := false #is partner currently stepping?

func _process(delta):
	if !is_stepping && abs(global_position.distance_to(step_target.global_position)) > step_distance:	##space between ik target and the target on node
		step()
		opposite_leg.step() ##so diagnal legs are synced for cleaner movement animation

func step():		##steps based on tweening? basicall global target and local target, update global to local if localmovedto far and "step" ther
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2
	is_stepping = true
	
	var t = get_tree().create_tween() ### wait wasnt that the "forbidden" command?
	t.tween_property(self, "global_position", half_way + owner.basis.y, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback((func(): is_stepping = false))
	
	#hopefully this works, I do not understand tween really at all, also why get_tree()?
	
	#### !!!!DONT FORGET to assign the target nodes to the target_ik nodes
	
	
