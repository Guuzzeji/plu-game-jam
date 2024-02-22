extends Node3D

# **Overview**
# Used to control player gun animations

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RESET")
	pass # Replace with function body.

# **About**
# Used to update gun prop position base on mouse
func _input(event):
	if event is InputEventMouseMotion:
		$Shotgun_SawedOff.position.x = lerp($Shotgun_SawedOff.position.x, 0.1 * -event.relative.normalized().x, 0.025)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Fix Gun Clipping through walls
	if $RayGunOffsetWall.is_colliding() and !$RayGunOffsetWall.get_collider().is_in_group("player"):
		$Shotgun_SawedOff.position = lerp($Shotgun_SawedOff.position, Vector3($Shotgun_SawedOff.position.x, -100, $Shotgun_SawedOff.position.z), 0.00025)
	else: 
		$Shotgun_SawedOff.position = lerp($Shotgun_SawedOff.position, $OrginalGunPos.position, 0.1)
		
	#Gun Swing
	$Shotgun_SawedOff.position.x = lerp($Shotgun_SawedOff.position.x, 0.0, 0.05)
	pass

# **About**
# Play animation when gun is fire
func fire_anim():
	$AnimationPlayer.play("Fire")
	pass
