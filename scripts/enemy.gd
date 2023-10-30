class_name Enemy
extends Blob

@export var gun: PackedScene = preload("res://scenes/guns/pistol.tscn")
@export var reaction_time: float = 0.5

var equipped_gun
var target = null
var reacting = false

@onready var reaction_timer: Timer = get_node("ReactionTimer")


func _ready():
	equipped_gun = gun.instantiate()
	gun_pos.add_child(equipped_gun)
	equipped_gun.world = world
	equipped_gun.owner = self
	
	reaction_timer.wait_time = reaction_time


func _process(delta):
	if target:
		if reacting:
			gun_pos.look_at(target.global_position)
			if sprite.scale.x == 1 and abs(get_angle_to(target.global_position)) > PI / 2:
				flip()
			elif sprite.scale.x != 1 and abs(get_angle_to(target.global_position)) < PI / 2:
				flip()
		else:
			if reaction_timer.time_left == 0:
				reaction_timer.start()


func _on_vision_cone_body_entered(body):
	if body.is_in_group("Players"):
		target = body

"""
if player not detected:
	idle (maybe move view form time to time?)
if player detected (through vision cone or hearing):
	wait for reaction time
	start targeting player
	calculate attack score and submit attack request

when attack request accepted:
	calculate inaccuracy and fire time
	fire at player

when out of ammo:
	wait reaction time
	reload
	wait reaction time

calculating attack score:
	distance to player
	line of sight to player
	weapon effectiveness against player current pos
	time since last attack
	is player aiming or firing at me
"""


func _on_reaction_timer_timeout():
	reacting = true
