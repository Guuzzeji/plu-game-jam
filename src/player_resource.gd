extends Resource

class_name Player_Data

@export var Health: int = 100
@export var Mana: int = 100
@export var Max_Mana: int = 100
@export var Max_Health: int = 100
@export var Mana_Inc_Sec: int = 1
@export var Bullet_Inventory: Array[PackedScene] # test with size 5
@export var Right_Barrel: PackedScene
@export var Left_Barrel: PackedScene
@export var Bullet_Info_Right_Barrel: Bullet_Type
@export var Bullet_Info_Left_Barrel: Bullet_Type
@export var Barrel_Delay: float = 0.15
