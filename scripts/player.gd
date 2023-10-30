class_name Player
extends Blob


@export var gun: PackedScene = preload("res://scenes/guns/pistol.tscn")
@export var focus_time_scale: float = 0.2
@export var screen_shake_ratio: float = 0.02
@export var inventory_scale_lerp: float = 0.5
@export var inventory_mouse_threshold: int = 30
@export var inventory_rotation_lerp: float = 0.5

var guns := []
var equipped_gun = null
var inv_selection: float
var inv_selected_gun: int

@onready var ammo_label: Label = get_node("HUD/AmmoLabel")
@onready var camera: Camera2D = get_node("Camera2D")
@onready var radial_inventory: Control = get_node("HUD/RadialInventory")
@onready var radial_inventory_outline: Control = get_node("HUD/RadialInventory/Circle/Outline")


func _ready():
	add_gun(gun)
	equip_gun(0)


func _process(_delta):
	if sprite.scale.x == 1 and abs(get_angle_to(get_global_mouse_position())) > PI / 2:
		flip()
	elif sprite.scale.x != 1 and abs(get_angle_to(get_global_mouse_position())) < PI / 2:
		flip()
	
	if Input.is_action_pressed("focus") or radial_inventory.visible:
		Engine.time_scale = focus_time_scale
		AudioServer.playback_speed_scale = focus_time_scale
	else:
		Engine.time_scale = 1
		AudioServer.playback_speed_scale = 1
	
	if Input.is_action_just_pressed("next_gun"):
		if equipped_gun == guns[-1]:
			equip_gun(0)
		else:
			equip_gun(guns.find(equipped_gun) + 1)
	if Input.is_action_just_pressed("prev_gun"):
		if equipped_gun == guns[0]:
			equip_gun(-1)
		else:
			equip_gun(guns.find(equipped_gun) - 1)
	
	if Input.is_action_just_pressed("inventory"):
		radial_inventory.show()
		equipped_gun.equipped = false
		ammo_label.hide()
	elif Input.is_action_just_released("inventory"):
		radial_inventory.hide()
		radial_inventory.scale = Vector2.ZERO
		equipped_gun.equipped = true
		ammo_label.show()
	
	if radial_inventory.visible:
		radial_inventory.scale = lerp(radial_inventory.scale, Vector2.ONE, inventory_scale_lerp)
		radial_inventory.rotation = -rotation
		
		if global_position.distance_to(get_global_mouse_position()) > inventory_mouse_threshold:
			inv_selection = snapped(global_position.angle_to_point(get_global_mouse_position()) + PI / 2, PI / 3)
			radial_inventory_outline.rotation = lerp(radial_inventory_outline.rotation, inv_selection, inventory_rotation_lerp)
			radial_inventory_outline.scale = lerp(radial_inventory_outline.scale, Vector2.ONE, inventory_scale_lerp)
		else:
			radial_inventory_outline.scale = lerp(radial_inventory_outline.scale, Vector2.ZERO, inventory_scale_lerp)
		
		if Input.is_action_just_pressed("fire"):
			inv_selected_gun = round(rad_to_deg(inv_selection) / 60)
			if inv_selected_gun == -1: inv_selected_gun = 5
			if equip_gun(inv_selected_gun): radial_inventory.hide()


func add_gun(gun_to_add):
	if guns.size() <= 6:
		var gun_inst = gun_to_add.instantiate()
		guns.append(gun_inst)
		gun_pos.add_child(gun_inst)
		gun_inst.hide()
		gun_inst.world = world
		gun_inst.owner = self
		gun_inst.fired.connect(get_recoiled)
		gun_inst.ammo_changed.connect(update_ammo_display)
		gun_inst.unequip()
		radial_inventory.get_node("Circle").get_node(str(guns.size() - 1)).set_icon(gun_inst.name)
		return true
	else:
		return false


func equip_gun(index):
	if index < guns.size():
		if equipped_gun:
			equipped_gun.unequip()
		
		equipped_gun = guns[index]
		equipped_gun.equip()
		
		return true
	else:
		return false


func get_recoiled(recoil_vector):
	apply_central_impulse(Vector2(recoil_vector.x * sprite.scale.x, recoil_vector.y).rotated(rotation))
	camera.shake(recoil_vector.length() * screen_shake_ratio)


func update_ammo_display(ammo_in_mag, ammo):
	ammo_label.text = str(ammo_in_mag) + " | " + str(ammo)


func pickup(item):
	add_gun(item)
