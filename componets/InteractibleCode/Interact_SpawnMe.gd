extends Interactable


@export var spawned_entity : NodePath #you must

@onready var spawnedCreature = "some Entity"
#change this to grab whatever the spawner wants to spawn

@onready var readyToSpawn = true #get from spawner, state
@onready var locked = false
@onready var state = WAIT
@onready var display = "Spawn: "  + spawnedCreature

@onready var PressedTimer = get_parent().get_node("PressedTimer")
@onready var LockingTimer = get_parent().get_node("LockingTimer")
@onready var ResetingTimer = get_parent().get_node("ResetingTimer")
@onready var button = TOP
#NEW IDEA
#SAME SCRIPT FOR BOTH BUTTONS
#TAKES THE NAME OF THE NODE IT IS ATTACHED TO TO DECIDE FUNCIONALITY
#ONE SPAWNS CREATURE, OTHER KILLS SAME CREATURE CREATED

enum {     #the states of the enemy 
	WAIT,
	SPAWNME, #default state, hit button to spawn something!
	LOCKED,  #Something is spawned, hit resset to kill entity, unlock, switch to SPAWNME
	OFF,	 #unused, disabled by external factor
	TOP,
	SIDE,
}

func _ready():
	if ("%s" % name == "TopButton"):
		button = TOP
	elif ("%s" % name == "SideButon"):
		button = SIDE

#remember, this tells the player's raycast to display what the button actually does
func get_interaction_text():	
	#if ()
	return display
	

#what presing E actually does. The raycast is what calls this. 
func interact():
	match button: 
		TOP:
			if (state == WAIT):
				state = SPAWNME
		SIDE:
			pass

	print("Interacted with %s " % name)
	print("state ", state)
	#the parent node that this script is attached to is the main node for the spawner
		#the main node has the function lockButton inside it, which plays the lock animation
	

	#animations
	
	#var RootEntityNode = spawned_entity.instantiate()
	#$SpawnPoint.add_child(RootEntityNode)
	
func _process(delta):
	match state:
		WAIT:
			pass
		SPAWNME:
			if (!locked):
				PressedTimer.start()
				get_parent().PressButton()
				locked = true #lock now that button was pressed
				print("pressed")
				
			if (PressedTimer.is_stopped()):
				print("timerstopped")
				get_parent().lockButton()
				LockingTimer.start()
				state = LOCKED
			#print(PressedTimer.is_stopped())
				
		LOCKED:
			display = "kill entity or hit reset"
			pass
		OFF:
			pass
