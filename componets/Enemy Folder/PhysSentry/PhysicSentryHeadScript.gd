extends RigidBody3D

@onready var target = load("res://componets/player/player_info.tres").Pbody
#@onready var PointA = load("res://misc_Testing_Scenes/radom dohikies/interpolationTests/PointA.tscn")
#@onready var PointB = load("res://misc_Testing_Scenes/radom dohikies/interpolationTests/PointB.tscn")
var target_position
var t = 0.0
var new_transform
# Called when the node enters the scene tree for the first time.
func _ready():
	
	target_position = target.position
	target_position = to_local(target_position)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$DetectionEyes.look_at(target.position,Vector3.UP)
	#var target_rotation = $DetectionEyes.global_transform.basis  
	##set_angular_velocity((target_rotation * global_transform.basis.inverse()).get_euler())
	##print(self.)
	#
	t += delta

	#self.transform = PointA.transform.interpolate_with(PointB.transform, t)
	
	##most complete!!!
	#t += delta
	#target_position = to_local(target_position)
	#new_transform = self.transform.looking_at(target_position, Vector3.UP )
	#new_transform = self.transform.interpolate_with(new_transform, t)
	#self.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
	
	
	
	#self.transform = self.transform.interpolate_with(target.transform, t)
	
	#var target_rotation = target.global_transform.basis    
	#set_angular_velocity((target_rotation * global_transform.basis.inverse()).get_euler())
	
	
	#var target_rotation = (self.transform.looking_at(target_position, Vector3.UP )).basis
	#set_angular_velocity((target_rotation * global_transform.basis.inverse()).get_euler())
	pass
