extends Resource

class_name Bullet_Type

@export var Name: String
@export var ID: int = 0
@export var Damage: int
@export var Speed: int
@export var Cost: int = 5
@export var Life_Time: float = 5
@export var Enemy_Bullet: bool = false
@export_file("*.tscn") var Path_Projectile: String
@export_file("*.tscn") var Path_Ammo: String

var Ammo: PackedScene
var Projectile: PackedScene

# Load PackSence for both ammo and Projectile
func _load():
	Ammo = load(Path_Ammo)
	Projectile = load(Path_Projectile)
	pass
