extends Node3D

#stateEngine
enum {     #the states of the enemy 
	WAITING,
	SPAWNME, #default state, hit button to spawn something!
	LOCKED,  #Something is spawned, hit resset to kill entity, unlock, switch to SPAWNME
	OFF,	 #unused, disabled by external factor
}

var state = SPAWNME; #spawnme is default
#delete this test var later, to see how animation player resets
var counter = 0

func _ready():
	pass

func _process(delta):	#animation note, playing an animation interupts another animation
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
	pass
	
func lockButton():
	$SpawnPad/AnimationPlayer.play("ButtonLocking")
	
func PressButton():
	$SpawnPad/AnimationPlayer.play("ButtonPressed")
#func spawnAndLock():
#	state = SPAWNME
	
