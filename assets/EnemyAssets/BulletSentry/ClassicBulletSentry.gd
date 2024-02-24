extends Node3D #yes I did just copy the code over.
#IDEA make invisible object with raytrace as long as sphere,
#it will detect if line of sight is blocked from the observer
#can also put it on a "camera" with the detection sphere

var sentry_head
var targetBody = null
var RayCastTargeter
var RayCastSightLine
var tresspassed = false
var reloadAnimaion ##delete?

@export var Bullet_Info : Bullet_Type ##think of it as a copy of the bullet info file 
@export var SentryInfo : Sentry_Data ##merge these two?
@onready var instanceHealth = SentryInfo.Health ##ok, sooooo SentryInfo.Health is a static... good to know
##oh hey first example of needing the @onready thingy!

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
	RayCastSightLine = get_node("DetectionEyes/LineOfSight")
	reloadAnimaion = get_node("SentryHead/BulletSentryHead/ReloadAnimation") as AnimationPlayer
	####slapdash fix to figure out this weird basis issue
	##issue: here self.transform.bsasis and sentry_head.transform.basis 
	######## do not start with the same value, they should....
#	sentry_head.transform.basis = self.transform.basis
	###AAAAA delete last line of code, when fixed
	#####AAAAA turns out the issue is that any rotation in the main level_test
	## will litterally just break the entire system, not even sure how or WHY
	##another idea, does looking_at use global or local basis? if global that would explain..
	## 					why it acts weird and "prases the sun" Really got to figure out why
	## WAIT IDEA ON HOW TO FIX do the origional thing with the whole sentry head looking
	## BUT GIVE THE DATA TO THE SENTRY HEAD, not the whole node. that way the head and the base 
	##tries to look at the player, but that data is sent to the head! though this has issues..
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	healthCheck()
	if (tresspassed):
		state = ATTACK ##make it so attack only activates if the eyes see somehting
		#eyes only activate when a body enteres the detection area
	#state Machine
	match state:
		PASSIVE:
			var new_transform 
			var speed = 0.01
	#		print(self.transform.basis)
	#		print(self.global_transform.basis)
	#		print(sentry_head.transform.basis)
	#		print(sentry_head.global_transform.basis)
	#		print()
	#		if (!(self.transform.basis == sentry_head.global_transform.basis)):
	#			new_transform = sentry_head.global_transform.interpolate_with(self.transform, speed)
	#			sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
				
				
				##(Basis (Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1)
			if (!(self.transform.basis == sentry_head.transform.basis)):
				new_transform = sentry_head.transform.interpolate_with(self.transform, speed)
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
			if (RayCastSightLine.is_colliding() && RayCastSightLine.get_collider().is_in_group("player")):
				var original_scale = self.basis.get_scale()# original_scale(self.basis.get_scale())
				var speed = .05
				var target_position = targetBody.position #self.transform.origin
				var new_transform
			
			#WORKING CODE SO FAR,    works by taking target position, transf
			#attacking codeorming to match it
		#		new_transform = sentry_head.global_transform.looking_at(target_position, Vec tor3.UP, )
		#		new_transform  = sentry_head.transform.interpolate_with(new_transform, speed)
		#		new_transform.inverse() #test, hopefully works
		#		sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
		#		print(new_transform)
		#		if (RayCastTargeter.is_colliding() && RayCastTargeter.get_collider().is_in_group("player")):
		#			fire()
		
		####another test version	
			#	print(target_position, to_local(target_position))
				#		print()
				target_position = to_local(target_position)
				new_transform = sentry_head.transform.looking_at(target_position, Vector3.UP )
			#	to_local(new_transform)
				new_transform  = sentry_head.transform.interpolate_with(new_transform, speed)
				#new_transform.inverse() #test, hopefully works
				sentry_head.transform = Transform3D (new_transform.basis, Vector3(0,1,0))
		#		sentry_head.transform = new_transform.basis
		#		print(new_transform)
				
				
				
				
				
				
			#attacking code
				if (RayCastTargeter.is_colliding() && RayCastTargeter.get_collider().is_in_group("player")):
					fire()
					
		DISABLED:
			pass
		DEAD:
			pass


func _on_area_3d_body_entered(body):  #When player enters the area, enter attack mode
	#print("A body entered")
	if body.is_in_group("player"):
		tresspassed = true 
		targetBody = body
		#print("EnteredNew: ", body)


func _on_area_3d_body_exited(body): #when player leaves go idle
	if body.is_in_group("player"):
		tresspassed = false
		state = PASSIVE
		#print("exitedNew:  ", body)

func inflictDamage(damage, hitspot, bulletInstance): #entities that damage use this
	instanceHealth = instanceHealth - damage
	
func healthCheck(): ##kill sentry if health drops below zero
	if instanceHealth <= 0:
		#print ("goodby world")
		queue_free() #delete self, litterally 

func fire(): #when attack state decides to fire the gun
	if ($Timer.is_stopped()):
		$SentryHead/BulletSentryHead/ReloadAnimation.play("BulletTurret/animation_model_SlideReload")
	#do not need to specify root
	#the bullet object file is in components_>bullets->nutbullet->nut_projectile.tscn file
		var firedBullet = load(Bullet_Info.Path_Projectile).instantiate() #creates the bullet with info
	#uses the info in bullet_Info to fabricate a functional bullet in firedBullet
		#firedBullet.transform = $SentryHead/BulletSpawnPoint.transform
		firedBullet.orginator = self	#cant hit self!
		firedBullet.Bullet_Info.Enemy_Bullet = true	#can now damage player
		$SentryHead/BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
	#place the bullet in the world, activates when placed.
		$Timer.start()
	pass

