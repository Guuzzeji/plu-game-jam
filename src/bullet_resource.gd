extends Resource

# **About**
# Bullet resource used to store bullet infomation in a standardize style
# Use this to create other bullets (basic types)
# Can be used to make custom bullets, but will require more work

# **Notes**
# Another Note: DON'T USE THIS IT WILL NOT WORK!!!!!
# Docs: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
# https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_notifications.html#ready-vs-enter-tree-vs-notification-parented
# Note:
# - https://github.com/godotengine/godot/issues/70575
#	Can't use _init() in this case b/c godot is design to not use export var when using _init()
#	Use notifcations instead, will load everything correctly

class_name Bullet_Type

@export var Name: String
@export var ID: int = 0

# Note: Have to do this b/c Godot doesn't like looping resources for some reason
# Can fix this by converting this into C# code
@export_file("*.tscn") var Path_Projectile: String
@export_file("*.tscn") var Path_Ammo: String

@export var Damage: int
@export var Speed: int
@export var Cost: int = 5 # This is mana cost
@export var Life_Time: float = 5 # This is how long the bullet will live, until self deletes itself
@export var Enemy_Bullet: bool = false
@export var Other_Info: Dictionary # Use this to add additional infomation for the bullet
