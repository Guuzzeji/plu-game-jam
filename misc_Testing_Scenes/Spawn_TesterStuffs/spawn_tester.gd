extends Node3D

@onready var locked = false
@onready var tempflag = true
@export var spawnBlueprint : PackedScene

@export var x_offset = 0.0
@export var y_offset = 0.0
@export var z_offset = 0.0
#var spawnBlueprint = preload("res://assets/EnemyAssets/BulletSentry/ClassicBulletSentry.tscn")
var spawned
#stateEngine
enum {     #the states of the enemy 
	WAITING,
	SPAWNME, #default state, hit button to spawn something!
	LOCKED,  #Something is spawned, hit resset to kill entity, unlock, switch to SPAWNME
	UNLOCKING, #handle the unlocking and de-spawning animations
	LOCKING,
	OFF,	 #unused, disabled by external factor
}
enum {     #the states of the enemy 
	WAIT,
#	SPAWNME, #default state, hit button to spawn something!
#	LOCKED,  #Something is spawned, hit resset to kill entity, unlock, switch to SPAWNME
#	OFF,	 #unused, disabled by external factor
	TOP,
	SIDE,
}

#signal ---

#var whichButton #generic variable that stores which button sent a signal
#idea: both buttons call the generic "on button pressed" function
#function checks which button activated it, then runs its action.

var state = WAIT; #spawnme is default
#delete this test var later, to see how animation player resets
var counter = 0

func _ready():
	
	var callable = Callable(self, "on_button_pressed")
	$SideButton.connect("on_interact", callable)
	$TopButton.connect("on_interact", callable)
	
	#print("connected?")
	pass
	
func on_button_pressed(whichButton):
	#print ("whichbutton: ", whichButton)
	if whichButton == "topButton":
		#print("did top Thing")
		if (state == WAIT):
			state = SPAWNME
		#print(locked
		#spawn_action()
	elif whichButton == "sideButton":
		#print("did side Thing")
		
		if (state == LOCKED):
			state = UNLOCKING
			locked = false
	else:
		print("error, no button?")
		
#func spawn_action():
	##if (!locked):
		##locked = true
		##PressButton()
	#
#func reset_action():
	##if (locked):
		##locked = false
		#unlockButton()

	
#func getCurrentAction():
	#if state == WAIT:
		#return "idle"
	#elif ((state == LOCKED) or (state == UNLOCKING)):
		#return "lock"
func _process(_delta):	#animation note, playing an animation interupts another animation
		match state:
			WAIT:
				pass
			SPAWNME:
				if (!locked): # "catch" -only fires once, does not repeat
					$PressedTimer.start()
					PressButton()
					locked = true #lock now that button was pressed
					#print("pressed")
					tempflag = true
					spawn_entity()
					#print("a")
					
					###IDEA FOR LATER
					###SHOVE THIS ALL INTO A WHILE LOOP??? might break the game...
					
				if ($PressedTimer.is_stopped() && tempflag): #wait for animation finish
					#print("timerstopped")
					tempflag = false
					#print(tempflag)
					lockButton()
					$LockingTimer.start()
					#print("b")
					
				if ($PressedTimer.is_stopped() and $LockingTimer.is_stopped()):
					#should only fire when both animations are done.
					state = LOCKED
					#print("c")
				#print(PressedTimer.is_stopped())
				
					
			LOCKED:
				#display = "kill entity or hit reset"
				if !is_instance_valid(spawned):
					state = UNLOCKING
					locked = false
				pass
			UNLOCKING:
				if (!locked):
					kill_entity() #just shoving this here? kill spawned
					$LockingTimer.start()
					unlockButton()
					#PressResetButton()
					locked = true #lock now that button was pressed
					print("")
					
				if ($LockingTimer.is_stopped()):
					print("")
					#$LockingTimer.start()
					locked = false #what even is the code at this point?
					state = WAIT
			OFF:
				pass

	#if $SpawnPad/AnimationPlayer.is_playing():
	#	print("playing")
	
	#match state:
	#	WAITING:
			#does nothing, just waits for button pressed
		#SPAWNME:
			#button has been hit, play 
		#LOCKED:
			
	
#	#BUT plaing the same animation will not interupt itself? does it que?
#	#$AnimationPlayer.play("ButtonPressed")
#	if (!$SpawnPad/AnimationPlayer.is_playing() && counter == 0):
#		$SpawnPad/AnimationPlayer.play("ButtonLocking")
#		counter = counter + 1
#	#elif (counter == 5):
#	#	print(counter)
#	if (!$SpawnPad/AnimationPlayer.is_playing() && counter == 1):
#		$SpawnPad/AnimationPlayer.play("KillButtonPressed")
#	#	counter = counter + 1
#
#	#$AnimationPlayer.play("KillButtonPressed")

	
func lockButton():
	$SpawnPad/AnimationPlayer.play("ButtonLocking")
	
func PressButton():
	$SpawnPad/AnimationPlayer.play("ButtonPressed")
func unlockButton():
	$SpawnPad/AnimationPlayer.play_backwards("ButtonLocking")
#func spawnAndLock():
#	state = SPAWNME

func spawn_entity():
	#spawned.position = self.global_position #tell turret to spawn in center ring
	spawned = spawnBlueprint.instantiate() #spawned is now a copy of what you want to spawn
	#spawned.rotate_y(PI)
	spawned.transform = spawned.transform.translated(Vector3(x_offset,y_offset,z_offset))
	add_child(spawned)
func kill_entity():
	if is_instance_valid(spawned): #soo google says this works,
		spawned.queue_free() #if spawned exists, delete it? "if" block prevents crashes
	
	
