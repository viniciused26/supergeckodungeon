extends Character

onready var sword: Node2D = get_node("Sword")
onready var sword_hitbox: Area2D = get_node("Sword/Node2D/Sprite/Hitbox")
onready var sword_animation_player: AnimationPlayer = sword.get_node("SwordAnimationPlayer")

export(int) var strength: int = 2 setget set_str
export(int) var dexterity: int = 2 setget set_dex
export(int) var magic: int = 2 setget set_mag
export(int) var vitality: int = 2 setget set_vit

func _ready() -> void:
	sword.get_node("SlashSprite").visible = false
	sword_hitbox.get_node("CollisionShape2D").disabled = true
	get_node("CollisionShape2D").disabled = false
	hp = 5 * vitality
	

func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	sword.rotation = mouse_direction.angle()
	sword_hitbox.knockaback_direction = mouse_direction
	if sword.scale.y == 1 and mouse_direction.x < 0:
		sword.scale.y = -1
	elif sword.scale.y == -1 and mouse_direction.x > 0:
		sword.scale.y = 1
	
	

func get_input() -> void:
	mov_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		mov_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		mov_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		mov_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		mov_direction += Vector2.UP
	
	if Input.is_action_just_pressed("ui_attack") and not sword_animation_player.is_playing():
		sword_animation_player.play("attack")

func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false

func set_str(new_str: int) -> void:
	strength = new_str

func set_dex(new_dex: int) -> void:
	dexterity = new_dex

func set_mag(new_mag: int) -> void:
	magic = new_mag

func set_vit(new_vit: int) -> void:
	vitality = new_vit
