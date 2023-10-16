extends Resource

# Docs: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
# https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_notifications.html#ready-vs-enter-tree-vs-notification-parented
# Note:
# - https://github.com/godotengine/godot/issues/70575
#	Can't use _init() in this case b/c godot is design to not use export var when using _init()
#	Use notifcations instead, will load everything correctly

class_name Bullet_Type

@export var Name: String
@export var ID: int = 0
@export_file("*.tscn") var Path_Projectile: String
@export_file("*.tscn") var Path_Ammo: String
@export var Damage: int
@export var Speed: int
@export var Cost: int = 5
@export var Life_Time: float = 5
@export var Enemy_Bullet: bool = false
@export var Other_Info: Dictionary

static var Ammo: PackedScene
static var Projectile: PackedScene

# Load PackSence for both ammo and Projectile
func _notification(what):
	if what == 1: # 1 means loading resource
		print(Path_Projectile)
		Ammo = load(Path_Ammo)
		Projectile = load(Path_Projectile)
