extends Weapon
#golden sword

onready var player: KinematicBody2D = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	hitbox.get_node("CollisionShape2D").disabled = true

func set_stats() -> void:
	hitbox.knockback_force = 160 + player.strength * 3
	hitbox.damage = player.strength * 0.7
	animation_player.playback_speed = 1.4 + player.dexterity * (1/20)

