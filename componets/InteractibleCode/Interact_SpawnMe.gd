extends Interactable


@onready var spawnedCreature = "some Entity" #replace??????
#change this to grab whatever the spawner wants to spawn

@onready var locked = false
@onready var state = WAIT
@onready var display = "Spawn: "  + spawnedCreature

@onready var button = TOP

signal on_interact
#NEW IDEA
#SAME SCRIPT FOR BOTH BUTTONS
#TAKES THE NAME OF THE NODE IT IS ATTACHED TO TO DECIDE FUNCIONALITY
#ONE SPAWNS CREATURE, OTHER KILLS SAME CREATURE CREATED

enum {     #the states of the enemy 
	WAIT,
	SPAWNME, #default state, hit button to spawn something!\SPANWME,
	LOCKED,  #Something is spawned, hit resset to kill entity, unlock, switch to SPAWNME
	UNLOCKING,
	LOCKING,
	OFF,	 #unused, disabled by external factor
	TOP,
	SIDE,
}

func _ready():
	if ("%s" % name == "TopButton"):
		button = TOP
	elif ("%s" % name == "SideButton"):
		button = SIDE

#remember, this tells the player's raycast to display what the button actually does
func get_interaction_text():	
	#print(get_parent().state)
	state = get_parent().state #get state of spawner and return button action
	if state == UNLOCKING or state == SPAWNME:
		return "do nothing"
	if button == TOP:
		match state:
			WAIT:
				return "spawn creature"
			LOCKED:
				return "do nothing"
	if button == SIDE:
		match state:
			WAIT:
				return "do nothing"
			LOCKED:
				return "kill and unlock"
	return display
	

#what presing E actually does. The raycast is what calls this. 
func interact():
	#print("buttonName: " , "%s" % name)
	#print(button)
	match button: 
		TOP:
			emit_signal("on_interact", "topButton")
			#if (state == WAIT):
				#state = SPAWNME
		SIDE:
			emit_signal("on_interact", "sideButton")

	#print("Interacted with %s " % name)
	#print("state ", state)
	#the parent node that this script is attached to is the main node for the spawner
		#the main node has the function lockButton inside it, which plays the lock animation
