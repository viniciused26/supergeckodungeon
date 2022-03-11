extends Node2D
class_name Weapon, "res://art/weapon/sword/sword.png"

export(bool) var on_floor: bool = false

onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var animated_sprite: AnimatedSprite = get_node("Node2D/AnimatedSprite")
onready var hitbox: Area2D = get_node("Node2D/AnimatedSprite/Hitbox")
onready var player_detector: Area2D = get_node("PlayerDetector")
onready var tween: Tween = get_node("Tween")

func _ready() -> void:
	if on_floor:
		animation_player.play("on_floor")

	if not on_floor:
		player_detector.set_collision_mask_bit(0, false)
		player_detector.set_collision_mask_bit(1, false)

func get_input() -> void:
	if Input.is_action_just_pressed("ui_attack") and not animation_player.is_playing():
		animation_player.play("attack")

func move(mouse_direction: Vector2) -> void:
	if not animation_player.is_playing():
		rotation = mouse_direction.angle()
		hitbox.knockaback_direction = mouse_direction
		if scale.y == 1 and mouse_direction.x < 0:
			scale.y = -1
		elif scale.y == -1 and mouse_direction.x > 0:
			scale.y = 1

func is_busy() -> bool:
	if animation_player.is_playing():
		return true
		
	return false

func set_stats() -> void:
	pass

func _on_PlayerDetector_body_entered(body: KinematicBody2D) -> void:
	if body != null:
		if body.able_to_pickup == true and not body.current_weapon.is_busy():
			player_detector.set_collision_mask_bit(0, false)
			player_detector.set_collision_mask_bit(1, false)
				
			animation_player.stop()
			animation_player.play("equipped")
			body.pick_up_weapon(self)
				
			position = Vector2.ZERO
				
		
	else:
		player_detector.set_collision_mask_bit(1, true)

func reset_for_pickup() -> void:
	player_detector.set_collision_mask_bit(0, true)
	player_detector.set_collision_mask_bit(1, true)

func dropped() -> void:
	animation_player.playback_speed = 1
	reset_for_pickup()
