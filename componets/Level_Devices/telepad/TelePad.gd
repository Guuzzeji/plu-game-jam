extends Node3D

@export var TeleChannel : int
signal teleported (channel, teleported_thingy)

var activeTeleporters = null ##array that has all teleporters
var sentPackage = false ##stops teleporter from teleporting thingy bact to which it came (no inf teleport trap)
var buddy_telepad = null ## the telepad which is partnered with the current one. 

##################################
##NOTES TO ADD
#####		export one way setting, export timer setting,

func _ready():
	add_to_group("Telepads") ##add telpad instance to group, this might be redundant
	activeTeleporters = get_tree().get_nodes_in_group("Telepads")
	##ok teleporters ars a bit funky
	##idea: person steps on pad, they are sent to other pad with same channel number
	##plan: all telepads are in a group, on startup connect telepads with same channel together
	##this means number of telepads is dynamic, limit on 2 per channel though
	for telepad in activeTeleporters:
		if (telepad.getChannel() == TeleChannel) && (telepad != self):	##found matching tele, send body there
			buddy_telepad = telepad ##found tele on same channel, assign it as the buddy telepad!
			break ##no point searching for more pads after finding the correct one
			
func _on_plate_detection_area_body_entered(body):
	if body.is_in_group("player") || body.is_in_group("Enemy") || body.is_in_group("teleportable"):
		if buddy_telepad  && !buddy_telepad.sentPackage: ##crashes if an unpaired telepad tries to teleport, poor lonely soul... telegun
			sentPackage = true	##tell self not to retrieve sent body
			sendBody(body)	## make sure entered body was not teleported here.


func _on_plate_detection_area_body_exited(body):
	##EDITOR WILL NOT SHUT UP ABOUT UNUSED BODY -prefix _box
	if buddy_telepad:
		buddy_telepad.sentPackage = false ## reset sending tele, here the buddy is the one that sent body
		##body left pad, safe to stat teleporting again!
	
#func grabBody(body): ##takes body that entered a tele and moves it to this one
	#if !buddy_telepad.just_used: ##only finish teleportation if you did not send out this body
		#body.global_position = $exit.global_position ##THE ACTUAL TELEPORTATION
		#sentPackage = false
	###the exit teleporter should fire this function
	
func sendBody(body): ##sends body that entered a tele to its buddy
	if true: ##only finish teleportation if you did not send out this body
		body.global_position = buddy_telepad.get_node("exit").global_position ##THE ACTUAL TELEPORTATION
	
func getChannel():
	return TeleChannel

#func routeTeleport(body): ##give telepad channel for routing reasons 
	
	#for (var i = 0, activeTeleporters.length(), i++ ):
		#activeTeleporters
	
	
