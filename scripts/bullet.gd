extends Area2D


@export var speed = 1000
@export var bullet_range = 100

@onready var bullet_origin = global_position

var shot_from


func _process(delta):
	global_position += Vector2(speed, 0).rotated(rotation) * delta
	
	if (global_position - bullet_origin).length() > bullet_range:
		queue_free()


func _on_body_entered(body):
	if body != shot_from and body.is_in_group("Blobs"):
		body.queue_free()
		queue_free()
