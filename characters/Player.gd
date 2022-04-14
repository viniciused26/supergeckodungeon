extends Character

const SWORD_SCENE: PackedScene = preload("res://weapons/sword/Sword.tscn")
const CLUB_SCENE: PackedScene = preload("res://weapons/morningstar/MorningStar.tscn")

onready var current_weapon: Node2D
var current_weapon_index: int = 0
var able_to_pickup: bool = true

onready var weapons: Node2D = get_node("Weapons")
onready var pickup_timer: Timer = get_node("PickupTimer")

export(int) var level: int = 1
export(int) var strength: int = 2
export(int) var dexterity: int = 2
export(int) var magic: int = 2
export(int) var vitality: int = 2

signal switch_weapon(new_texture)

func _ready() -> void:
	_restore_previous_state()
	get_node("CollisionShape2D").disabled = false

func _restore_previous_state() -> void:
	self.hp = SavedData.hp
	max_hp = SavedData.max_hp
	level = SavedData.level
	strength = SavedData.strength
	dexterity = SavedData.dexterity
	magic = SavedData.magic
	vitality = SavedData.vitality
	
	if SavedData.weapons.empty():
		var sword = SWORD_SCENE.instance()
		sword.show()
		sword.position = Vector2.ZERO
		weapons.add_child(sword)
		
		var club = CLUB_SCENE.instance()
		club.hide()
		club.position = Vector2.ZERO
		weapons.add_child(club)
		emit_signal("switch_weapon", club.get_texture())
	else:
		for wpn in SavedData.weapons:
			wpn = wpn.duplicate()
			wpn.hide()
			wpn.position = Vector2.ZERO
			weapons.add_child(wpn)
	
	current_weapon = weapons.get_child(SavedData.equipped_weapon_index)
	current_weapon.animation_player.play("equipped")
	current_weapon.show()
	current_weapon_index = SavedData.equipped_weapon_index
	
	if current_weapon_index == 0:
		emit_signal("switch_weapon", weapons.get_child(1).get_texture())
	else:
		emit_signal("switch_weapon", weapons.get_child(0).get_texture())

func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	if is_instance_valid(current_weapon):
		current_weapon.move(mouse_direction)

func get_input() -> void:
	if is_instance_valid(current_weapon):
		mov_direction = Vector2.ZERO
		if Input.is_action_pressed("ui_down"):
			mov_direction += Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			mov_direction += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			mov_direction += Vector2.RIGHT
		if Input.is_action_pressed("ui_up"):
			mov_direction += Vector2.UP
		if not current_weapon.is_busy():
			if Input.is_action_just_pressed("ui_switch_weapon"):
				_switch_weapon()
		
		current_weapon.get_input()

func _switch_weapon() -> void:
	if current_weapon.get_index() == 1:
		current_weapon_index = 0
	else:
		current_weapon_index = 1
	
	if is_instance_valid(weapons.get_child(current_weapon_index)):
		current_weapon.hide()
		emit_signal("switch_weapon", current_weapon.get_texture())
		current_weapon = weapons.get_child(current_weapon_index)
		current_weapon.show()
		current_weapon.animation_player.play("equipped")
		SavedData.equipped_weapon_index = current_weapon.get_index()

func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false

func  pick_up_weapon(weapon: Node2D) -> void:
	var weapon_spot = weapon.get_parent()
	weapon_spot.call_deferred("remove_child", weapon)
	
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	 
	current_weapon.hide()
	_drop_weapon(weapon_spot)
	
	current_weapon = weapon
	
	able_to_pickup = false
	pickup_timer.start()

func _drop_weapon(spot: Node2D) -> void:
	var weapon_to_drop: Node2D = current_weapon
	weapons.call_deferred("remove_child", weapon_to_drop)
	spot.call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.set_deferred("owner", spot)
	
	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	if throw_dir.x > 0:
		weapon_to_drop.rotation_degrees = 0
	elif throw_dir.x < 0:
		weapon_to_drop.rotation_degrees = 180
	
	weapon_to_drop.animation_player.play("on_floor")
	weapon_to_drop.show()
	weapon_to_drop.dropped()

func _on_PickupTimer_timeout():
	able_to_pickup = true
