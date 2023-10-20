extends Resource

class_name Player_Data

@export var Health: int = 100

@export var Mana: int = 100
@export var Max_Mana: int = 100
@export var Max_Health: int = 100
@export var Mana_Inc_Sec: int = 1
@export var Mana_Timer: float = 0.15

@export var Bullet_Inventory: Array[Bullet_Type] # test with size 5

@export var Right_Barrel: Bullet_Type
@export var Left_Barrel: Bullet_Type

@export var Barrel_Delay: float = 0.15

@export var SPEED: float = 450.0
@export var ACCL: float = 0.20
@export var DE_ACCL: float = 0.08
@export var JUMP_VELOCITY: float = 5.66 # 4.5
