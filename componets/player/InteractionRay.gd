extends RayCast3D
## NOTE NOTE WARNING WARNING
## INTERACTION RAY CASTS ARE ALL ON COLLISION MASK 3!!!
# detects camera for some reason, why does camera have EVERY collision mask?
var current_collider #used to store what the collider is looking at, default is null

@onready var interaction_label = $"../../../PlayerHud".get_node("InteractText")
	#WHY IS THIS THE ONE THAT WORKS$

#the label on the ui that we want to display what we are looking at

func _ready():
	set_interactionLabel_text("") #execute the set/display interaction lable function once.
	

#function used to set the text of the interaciton label
func set_interactionLabel_text(inputText):
	if !inputText: #if there was no input text, this reads true, displays nothing 
		interaction_label.set_text("nothing")
		interaction_label.set_visible(false) #hide the label since nothing to show
	else:
		#thsi does not appear to work in godot 4.0 var interact_key = OS.get_(InputMap.get_signal_connection_list("Interact"))
		var interact_key = "E" #we will have to set this manually for now.
		interaction_label.set_text("Press %s to %s" % [interact_key, inputText]) 
		interaction_label.set_visible(true)


func _process(delta):
	var collider = get_collider() 
	#print(current_collider)  #default is null
	#print(collider)		  #default is Object#null

	if (is_colliding() and (collider is Interactable)):
		if current_collider != collider:
			set_interactionLabel_text(collider.get_interaction_text())
			#the object we are looking at should habe collider text if it is "interactable"
			#we will display this text on the ui using the above function.
			current_collider = collider
		else:
			set_interactionLabel_text(collider.get_interaction_text())
			#constantly update interaction description for changes

		if Input.is_action_just_pressed("Interact"): #assuming we can change action pressed
			set_interactionLabel_text(collider.get_interaction_text()) #collider text might cjhange
			collider.interact() #ooooo interesting, runs the interact function that 
			#is attached to colliding object

	elif current_collider: # != null?, I believe curretCollider has null by default, this resets it to null
		current_collider = null #reset to null
		set_interactionLabel_text("") #clear the "press F to pay respects"

		#breakdown
		#step 1: raycast has collided with something and is "interactable"
		#step 2: is this the same object as before? 
			#yes -> collider = new collider and  display collider info
			#no  ->
		#step 3: if player hits "interact"
			#tell object it has been interacted with
			#check object's interaction text to see if it has changed
		#incomplete finish later
#some quick notes
	#we have: made a generic "interactable" script,  (Made just for this task)
		#made: "interaction testing label" (Made just for this task)
		#added collision hitboxes set to collsion mask 3 to "interactables" (modified pre existing things)
		#attached the InteractionTest script to said collision hitboxes (made just for this task)
		#added a raycast to the camera of the player that detects these interactable hitboxes (modifed player)	
		#note, not in order, mostly,.
		#note 2, when I change a physics detector, it changes the collision node to a white custom "interact" node apparently
		#note 3, the % name thing grabs the name of the staticbody node with the interactionTest script attached.



