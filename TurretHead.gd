extends CharacterBody3D

var targetBody = null
var targetSighted = false;
enum {
	PASSIVE,
	ATTACK,
	DISABLED,
	DEAD,
}

var state = PASSIVE;

func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match state:
		PASSIVE:
			pass
		ATTACK:
			var speed = .01
			var target_position = targetBody.position #self.transform.origin
			var new_transform = self.transform.looking_at(target_position, Vector3.UP)
			#self.transform  = self.transform.interpolate_with(new_transform, speed)
			self.transform  = new_transform
			#print ("target: ", targetBody.position)
			#print ("transform: ", new_transform)
		DISABLED:
			pass
		DEAD:
			pass
	pass


func _on_area_3d_body_entered(body):  #MAKE STATE MACHINE, SHOVE MOST BELOW CODE INSIDE
	print("entered: ", body)
	print("the self; ", self)
	if body.is_in_group("player"):
		state = ATTACK
		targetBody = body
		print("entered: ", body)
		print("the self; ", self)
	
	#if body.is_in_group("player"):
		#print("detected")
		#var speed = 5
		#var target_position = body.position #self.transform.origin
		#var new_transform = self.transform.looking_at(target_position, Vector3.UP)
		#self.transform  = self.transform.interpolate_with(new_transform, speed)
	#pass # Replace with function body.


func _on_area_3d_body_exited(body):
	print("exited:  ", body)
	state = PASSIVE
	#pass # Replace with function body.
