extends Node3D
#IDEA make invisible object with raytrace as long as sphere,
#it will detect if line of sight is blocked from the observer
#can also put it on a "camera" with the detection sphere

var sentry_head
var targetBody = null
var RayCastTargeter
@export var Bullet_Info : Bullet_Type #think of it as a copy of the bullet info file 
#creates a object that contains all bullet data and links to launch code
#to function, export puts the data in the right sentry.gd terminal
#you must import the bullet tscn file so the Bullet_Type actually works

enum {     #the states of the enemy 
	PASSIVE,
	ATTACK,
	DISABLED,
	DEAD,
}

#var bullets = Array[Bullet_Type](size 1)
#Bullet_Type is either the array name or var (an object) being stored in arary


var state = PASSIVE;

func _ready():
	sentry_head = get_node("SentryHead") #refer to the head of unit to follow player.
	RayCastTargeter = get_node("SentryHead/RayCast3D")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match state:
		PASSIVE:
	#		var new_transform 
	#		var speed = 0.01
	#		if (!(self.transform.basis == sentry_head.transform.basis)):
	#			new_transform = sentry_head.global_transform.interpolate_with(self.transform, speed)
	#			sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
	#			if (new_transform.basis.is_equal_approx(self.transform.basis)):
	#				print("in range")
	#			print("returning")
	#			print(self.transform.basis)
	#			print(sentry_head.transform.basis)
	#		else:
	#			print("docked")
			pass
		ATTACK:
			#OOOOO TEST THIS OUT with vectors!1
			
			var  original_scale =   self.basis.get_scale()# original_scale(self.basis.get_scale())
	#		print (self.basis.get_scale())
	#		print (sentry_head.basis.get_scale())
			#original_scale Vector3 = self.get_scale()
			var speed = .05
			var target_position = targetBody.position #self.transform.origin
			var new_transform
			
			
			
			#WORKING CODE SO FAR,    works by taking target position, transforming to match it
			new_transform = sentry_head.global_transform.looking_at(target_position, Vector3.UP, )
			new_transform  = sentry_head.global_transform.interpolate_with(new_transform, speed)
			sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
			
			#attacking code
			if (RayCastTargeter.is_colliding() && RayCastTargeter.get_collider().is_in_group("player")):
				fire()
				
			
		DISABLED:
			pass
		DEAD:
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


func _on_area_3d_body_exited(body): #when player leaves go idle
	if body.is_in_group("player"):
		state = PASSIVE
		print("exited:  ", body)
	


func fire(): #when attack state decides to fire the gun
	if ($Timer.is_stopped()):
	#do not need to specify root
	#the bullet object file is in components_>bullets->nutbullet->nut_projectile.tscn file
		var firedBullet = Bullet_Info.Projectile.instantiate() #creates the bullet with info
	#uses the info in bullet_Info to fabricate a functional bullet in firedBullet
		$SentryHead/BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
	#place the bullet in the world, activates when placed.
		$Timer.start()
	pass
