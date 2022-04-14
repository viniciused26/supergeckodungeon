extends Area2D

onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")

func _on_Stairs_body_entered(_body: KinematicBody2D) -> void:
	SavedData.weapons = []
	
	for wpn in _body.weapons.get_children():
		SavedData.weapons.append(wpn.duplicate())
	
	for wpn in _body.weapons.get_children():
		wpn.queue_free()
	
	
	collision_shape.set_deferred("disable", true)
	SceneTransistor.start_transition_to("res://Game.tscn")


