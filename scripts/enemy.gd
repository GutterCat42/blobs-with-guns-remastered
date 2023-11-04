class_name Enemy
extends Blob

@export var gun: PackedScene = preload("res://scenes/guns/pistol.tscn")
@export var reaction_time: float = 0.5
@export var time_between_attacks: float = 1
@export var attack_time: float = 0.2

var equipped_gun
var target = null
var reacting = false
var attacking = false
var time_since_last_attack: float = 0
var attack_ready := true

@onready var reaction_timer: Timer = get_node("ReactionTimer")
@onready var raycast: RayCast2D = get_node("RayCast2D")
@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var burst_timer: Timer = get_node("BurstTimer")
@onready var attack_coordinator: Node2D = get_parent().get_node("AttackCoordinator")


func _ready():
	equipped_gun = gun.instantiate()
	gun_pos.add_child(equipped_gun)
	equipped_gun.world = world
	equipped_gun.owner = self
	
	reaction_timer.wait_time = reaction_time
	attack_timer.wait_time = time_between_attacks


func _process(delta):
	if not is_instance_valid(target): target = null
	
	if target:
		if reacting:
			if can_see_target():
				gun_pos.look_at(target.global_position)
			else:
				reacting = false
			
			if calculate_attack_score() > attack_coordinator.attacker_score:
				if attack_coordinator.attacker: attack_coordinator.attacker.attacking = false
				attack_coordinator.attacker = self
				attack_coordinator.attacker_score = calculate_attack_score()
				attacking = true
			
			if sprite.scale.x == 1 and abs(get_angle_to(target.global_position)) > PI / 2:
				flip()
			elif sprite.scale.x != 1 and abs(get_angle_to(target.global_position)) < PI / 2:
				flip()
			
			if attacking:
				if attack_ready:
					if equipped_gun.can_shoot and not equipped_gun.reloading and equipped_gun.ammo_in_mag > 0:
						equipped_gun.fire()
						attack_timer.start()
						attack_ready = false
			
		else:
			if reaction_timer.time_left == 0:
				reaction_timer.start()


func _on_vision_cone_body_entered(body):
	if body.is_in_group("Players"):
		target = body


func can_see_target():
	if target:
		raycast.target_position = to_local(target.global_position)
		if raycast.is_colliding() and raycast.get_collider() == target:
			return true
		else:
			return false


func calculate_attack_score():
	var atk_score: float = 0
	
	if target:
		#atk_score += equipped_gun.bullet_range / global_position.distance_to(target.global_position)
		if can_see_target(): atk_score += 1
		atk_score += hp
		atk_score += 1 / global_position.distance_to(target.global_position)
		return atk_score
	
	else:
		return false


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


func _on_attack_timer_timeout():
	attack_ready = true
