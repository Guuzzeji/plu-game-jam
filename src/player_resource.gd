extends Resource

# **Overview**
# Store player infomation in a standardize way and allow other Nodes to 
# use player data for their own needs

class_name Player_Data

# Health
@export var Health: int = 100

# Mana
@export var Mana: int = 100
@export var Max_Mana: int = 100
@export var Max_Health: int = 100
@export var Mana_Inc_Sec: int = 1
@export var Mana_Timer: float = 0.15

# Bullet inventory
@export var Bullet_Inventory: Array[Bullet_Type] # test with size 5

# Shooting barrels
var Inv_Index_Left_Barrel: int = 0
var Inv_Index_Right_Barrel: int = 0

# Barrel delay when gun is fire
@export var Barrel_Delay: float = 0.15
@export var Barrel_Switch_Delay: float = 0.25

# Player movement
@export var SPEED: float = 450.0
@export var ACCL: float = 0.20
@export var DE_ACCL: float = 0.08
@export var JUMP_VELOCITY: float = 5.66 # 4.5

# Player states
enum MovementState {WALKING, IDLE, JUMPING, WALKING_AND_JUMPING, FALLING, WALKING_AND_FALLING}
enum BarrelState {SHOOTING, SWITCHING_BULLETS_LEFT, SWITCHING_BULLETS_RIGHT, IDLE, SHOOTING_DELAY}
enum HealthState {HIT, FINE, DEAD, ALMOST_DEAD}
enum ManaState {LOW, ZERO, RECHARGING, FULL}
var Curret_MovementState
var Current_BarrelState
var Current_HealthState
var Current_ManaState

# Player Body
var Pbody = Node3D
var Player_Hud
#Allows if hitbody = playerBody in the bullet code, make static?

# **About**
# Used for taking damge off of player and updating player state
# Note: may need to make changes to this later down the road
func take_damge(damge: int):
	Current_HealthState = HealthState.HIT
	Health -= damge
	pass
