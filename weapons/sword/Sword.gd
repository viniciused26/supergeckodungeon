extends Weapon
#sword

onready var player: KinematicBody2D = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	hitbox.get_node("CollisionShape2D").disabled = true

func set_stats() -> void:
	hitbox.knockback_force = 150 + player.strength * 3
	hitbox.damage = player.strength * 0.5
	animation_player.playback_speed = 1 + (player.dexterity * 0.05)

