extends RigidBody2D


@onready var shell_manager: Node2D = get_parent().get_node("ShellManager")


func _ready():
	shell_manager.shells.append(self)


func _on_timer_timeout():
	shell_manager.shells.erase(self)
	queue_free()
