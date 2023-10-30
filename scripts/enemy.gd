class_name Enemy
extends Blob

@export var gun: PackedScene = preload("res://scenes/guns/pistol.tscn")


func _ready():
	add_gun(gun)
	equip_gun(0)
