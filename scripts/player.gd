class_name Player
extends Blob


@export var gun = preload("res://scenes/guns/gun.tscn")

var guns = []
var equipped_gun = null


func _ready():
	add_gun(gun)
	equip_gun(0)


func _process(_delta):
	if sprite.scale.x == 1 and abs(rad_to_deg(get_angle_to(get_global_mouse_position()))) > 90 or sprite.scale.x == 1 and if abs(rad_to_deg(get_angle_to(get_global_mouse_position()))) < 90:
		flip()

func add_gun(gun_to_add):
	var gun_inst = gun_to_add.instantiate()
	guns.append(gun_inst)
	gun_pos.add_child(gun_inst)
	gun_inst.hide()
	gun_inst.world = get_parent()
	gun_inst.owner = self
	gun_inst.fired.connect(get_recoiled)


func equip_gun(index):
	if equipped_gun:
		equipped_gun.hide()
	
	equipped_gun = guns[index]
	equipped_gun.show()


func get_recoiled(recoil_vector):
	apply_central_impulse(Vector2(recoil_vector.x * sprite.scale.x, recoil_vector.y).rotated(rotation))
