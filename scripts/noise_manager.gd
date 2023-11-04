extends Node2D


var noises := []


func add_noise(location: Vector2, strength: float, duration: float):
	noises.append([location, strength])
	await get_tree().create_timer(duration).timeout
	noises.remove_at(noises.find([location, strength]))
