extends Node3D
#IDEA make invisible object with raytrace as long as sphere,
#it will detect if line of sight is blocked from the observer
#can also put it on a "camera" with the detection sphere

var sentry_head
var targetBody = null
var targetBodyGroup = "Enemy"
var RayCastTargeter
var RayCastSightLine
var tresspassed = false;
@export var Bullet_Info : Bullet_Type #think of it as a copy of the bullet info file 
#creates a object that contains all bullet data and links to launch code
#to function, export puts the data in the right sentry.gd terminal
#you must import the bullet tscn file so the Bullet_Type actually works

##code to test launching physics objects like spheres
var bomblauncher = true	
var firedBullet

@export var bombdata : PackedScene
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
	RayCastSightLine = get_node("DetectionEyes/LineOfSight")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (tresspassed):
		state = ATTACK ##make it so attack only activates if the eyes see somehting
		#eyes only activate when a body enteres the detection area
	#state Machine
	match state:
		PASSIVE:
			var new_transform 
			var speed = 0.01
	##		print(self.transform.basis)  ##test code remove
	##		print(sentry_head.transform.basis)##test code remove
			if (!(self.transform.basis == sentry_head.transform.basis)):
				new_transform = sentry_head.global_transform.interpolate_with(self.transform, speed)
				sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
	#			if (new_transform.basis.is_equal_approx(self.transform.basis)):
	#				print("in range")
	#			print("returning")
	#			print(self.transform.basis)
	#			print(sentry_head.transform.basis)
	#		else:
	#			print("docked")
			pass
		ATTACK:	
			#can see player code, eyes always sees player, raycast checks if can see player
			#raycast only detects the first object it hits, backbone of if statement
			$DetectionEyes.look_at(targetBody.position,Vector3.UP)
			#print(targetBody.position)
			if (RayCastSightLine.is_colliding() && RayCastSightLine.get_collider() && RayCastSightLine.get_collider().is_in_group("player")):
				var  original_scale = self.basis.get_scale()# original_scale(self.basis.get_scale())
				var speed = .05
				var target_position = targetBody.position #self.transform.origin
				var new_transform
			
			#WORKING CODE SO FAR,    works by taking target position, transforming to match it
				new_transform = sentry_head.global_transform.looking_at(target_position, Vector3.UP, )
				new_transform  = sentry_head.global_transform.interpolate_with(new_transform, speed)
				sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
			
			#attacking code
				if (RayCastTargeter.is_colliding() && RayCastTargeter.get_collider().is_in_group(targetBodyGroup)):
					fire()
					
		DISABLED:
			pass
		DEAD:
			pass


func _on_area_3d_body_entered(body):  #When player enters the area, enter attack mode
	if body.is_in_group(targetBodyGroup):
		#print("ENTERED ", body)
		if targetBody == null:
			tresspassed = true 
			targetBody = body
			print("new target: ", targetBody)
		else:
			print(targetBody)


func _on_area_3d_body_exited(body): #when player leaves go idle
	if body.is_in_group(targetBodyGroup):
		if targetBody == body:
			tresspassed = false
			state = PASSIVE
			print(targetBody)
		#print("exited:  ", body)
	


func fire(): #when attack state decides to fire the gun
	if ($Timer.is_stopped()):
		if bomblauncher:
			firedBullet = bombdata.instantiate()
			firedBullet.orginator = self
			##since rthis is not working, i will emit signal with span node point
			# emit fireBomb($SentryHead/BulletSpawnPoint.localposition, object?)
			
		else:
			firedBullet = Bullet_Info.Projectile.instantiate() #creates the bullet with info
	#uses the info in bullet_Info to fabricate a functional bullet in firedBullet
	#do not need to specify root
	#the bullet object file is in components_>bullets->nutbullet->nut_projectile.tscn file
		
		$SentryHead/BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
	#place the bullet in the world, activates when placed.
		$Timer.start()
	pass
