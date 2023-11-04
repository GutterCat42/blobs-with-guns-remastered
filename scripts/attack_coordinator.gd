extends Node2D


var attacker
var attacker_score: float = 0


func _process(delta):
	if not is_instance_valid(attacker):
		attacker = null
		attacker_score = 0


func apply_for_attack(applicant, applicant_score):
	if applicant_score > attacker_score:
		if attacker: attacker.attacking = false
		attacker = applicant
		attacker_score = applicant_score
		applicant.attacking = true
