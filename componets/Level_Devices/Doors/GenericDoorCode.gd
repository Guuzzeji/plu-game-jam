extends CSGMesh3D
##### BEHOLD! MY SUPER COMPLEX DOOR CODE!!!!!
#### just connect any signal you want to the function in the signal tab, THEN----!!!!
#### THEN pick (bottem mid-ish button) what function you want it to call/activate, otherwise it adds a new functon :C

##NOTE: REDO THIS FKING CODE SO IT USES QUE_FREE

@export var closed = true

# Called when the node enters the scene tree for the first time.
func _ready():	##door appears closed in editor, this opens it if you want it default open
	if closed:
		_close_door()
	else:
		_open_door()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _open_door():
	visible = false
	set_collision_layer_value(1, false)


func _close_door():
	visible = true
	set_collision_layer_value(1, true)

func _toggle_door():
	closed = !closed
	_ready() ### feels jank but should work fine!
