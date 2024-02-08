extends RayCast3D

@export var Bullet_Info : Bullet_Type
@export var Player_Info : Player_Data
@export var Life_Timer : Timer

var orginator = Node3D
var target_point : Vector3 ## The end point of laser
var NoBeam = true
var mesh_instance : MeshInstance3D	## from line code, made field so damage function can also despawn the visual laser
# Called when the node enters the scene tree for the first time.

@export var linepolygon : CSGPolygon3D
var Distance_To_Target : float

@export var radius = .125
@export var resolution = 180
@export var extraDepth : float = .25	## so beam visually collides with body
func _ready():
	#print(orginator, " ", orginator.owner)
	#add_exception(orginator.owner)
	set_as_top_level(true) # Sets node to root level of the node tree (basically at sets parent to level/world node)
	self.add_exception(orginator)
	Life_Timer.timeout.connect(_on_life_timer_timeout) # Connecting singal (time out) to func
	Life_Timer.one_shot = true
	Life_Timer.start(Bullet_Info.Life_Time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
##documentation for this dark magic: https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	if self.is_colliding():
		if self.get_collider().owner == orginator:
			self.add_exception(get_collider())
			return
		elif NoBeam:
			NoBeam = false
			CreateLaser()
			damage(get_collider())	##note, issue with owners here

func _on_life_timer_timeout():
	if mesh_instance: ## if mesh instance is not null, delete it
		mesh_instance.queue_free()
	queue_free()

func damage(body):		##if an enemy (say evil rock) cannot be damaged, best not crash!
	#print(Bullet_Info.Damage)
	if body.has_method("inflictDamage"):	##if can inflict damage, damage it
		body.inflictDamage(Bullet_Info.Damage, body, self)


func CreateLaser():
	target_point = get_collision_point()
	#print(target_point)
	Distance_To_Target = self.position.distance_to(target_point)
	#print(Distance_To_Target)
	var circle = PackedVector2Array()	## modified version of "3D Lines Tutorial Godot" by "Apocalyptic Phosphorus"
	for degree in resolution:
		var x = radius * sin(PI * 2 * degree / resolution)
		var y = radius * cos(PI * 2 * degree / resolution)
		var coords = Vector2(x , y)
		circle.append( coords )
	linepolygon.depth = Distance_To_Target + extraDepth
	linepolygon.polygon = circle
	


		####DEPRECATED CODE, MAY USE LATER
#####################################################################################################
## ALL CODE i FOUND ONLINE: https://github.com/Ryan-Mirch/Line-and-Sphere-Drawing/blob/main/Draw3D.gd
## FROM YOUTUBRE VIDEO: https://www.youtube.com/watch?v=JnrhURF1jgM
## I will / have already tweaked this code for bullet compatability 
func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0): ### should explain self, note persist is how klong it lasts
	mesh_instance = MeshInstance3D.new()	## made global
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	print(immediate_mesh)
	print(immediate_mesh.create_outline(.5))
	immediate_mesh.surface_end()
	
	var outline = immediate_mesh.create_outline(10.0)	## added by me
	print(outline)
	#var mesh_instance2 = MeshInstance3D.new()
	#mesh_instance2 = outline
	#mesh_instance2.surface_set_material(material)

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.rim_enabled	## added by me
	material.rim_tint = 1.0	## added by me
	material.rim	## added by me
	#material.rim_col = Color.RED

	return await final_cleanup(mesh_instance, persist_ms)


func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
