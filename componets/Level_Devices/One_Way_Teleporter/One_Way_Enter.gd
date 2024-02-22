extends Node3D

@export var One_Way_TeleChannel : int
#signal teleported (channel, teleported_thingy)

var active_Exit_Points = null ##array that has all teleporters
var activated = false ##stops teleporter from teleporting thingy bact to which it came (no inf teleport trap)
var exit_point = null ## the telepad which is partnered with the current one. 

func _ready():
	#add_to_group("Exit_Teleport_Points") ##add telpad instance to group, this might be redundant
	active_Exit_Points = get_tree().get_nodes_in_group("Exit_Teleport_Points")
	##ok teleporters ars a bit funky
	##idea: person steps on pad, they are sent to other pad with same channel number
	##plan: all telepads are in a group, on startup connect telepads with same channel together
	##this means number of telepads is dynamic, limit on 2 per channel though
	for exitPoint in active_Exit_Points:
		if exitPoint.getChannel() == One_Way_TeleChannel:	##found matching tele, send body there
			exit_point = exitPoint ##found tele on same channel, assign it as the buddy telepad!
			break ##no point searching for more pads after finding the correct one


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_tele_detector_body_entered(body):
	update_exits() ##temp code probably to just fix an issue, see if can work around or is fine to leave in?
	if body.is_in_group("player"): # || body.is_in_group("Enemy") || body.is_in_group("teleportable"):
		if exit_point: ##crashes if an unpaired telepad tries to teleport, poor lonely soul... telegun
			activated = true	##tell self not to retrieve sent body
			sendBody(body)	## make sure entered body was not teleported here.
	pass # Replace with function body.

func update_exits():
	active_Exit_Points = get_tree().get_nodes_in_group("Exit_Teleport_Points")
	for exitPoint in active_Exit_Points:
		if exitPoint.getChannel() == One_Way_TeleChannel:	
			exit_point = exitPoint 
			break 

func sendBody(body): ##sends body that entered a tele to its buddy
	var originalScale = body.get_scale() ##some dumbasss solution I found online FUCK WHOEVER THOUGHT ROTATOIN AND SCALE SHOULD SHARE A PARAMETER
	#body.global_position = exit_point.get_node("ExitPoint").global_position ##THE ACTUAL TELEPORTATION
	#print(body.get_global_transform().basis.z, exit_point.get_node("ExitPoint").get_global_transform().basis.z)
	#body.global_transform = exit_point.get_node("ExitPoint").global_transform.orthonormalized()
	#var TEMP =  exit_point.get_node("ExitPoint").get_global_transform().basis
	#body.global_transform.basis = exit_point.get_node("ExitPoint").get_global_transform().basis.orthonormalized()
	body.global_transform = exit_point.get_node("ExitPoint").get_global_transform()
	body.scale = originalScale
	body.velocity = Vector3.ZERO
	##https://www.reddit.com/r/godot/comments/10bpeyt/how_to_keep_scale_after_transforming_basis_godot/
	## 5 min code took 2 HOURS
