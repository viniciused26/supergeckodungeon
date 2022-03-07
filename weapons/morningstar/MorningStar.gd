extends Weapon

onready var player: KinematicBody2D = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	hitbox.get_node("CollisionShape2D").disabled = true

func set_stats() -> void:
	print(name)
	hitbox.knockback_force = 150 + player.strength * 6
	hitbox.damage = player.strength * 1
	animation_player.playback_speed = 0.6 + (player.dexterity * 0.05)

