extends Character

var current_weapon: Node2D
var current_weapon_index: int
var able_to_pickup: bool = true

onready var weapons: Node2D = get_node("Weapons")
onready var pickup_timer: Timer = get_node("PickupTimer")

export(int) var level: int = 1 setget set_lvl
export(int) var strength: int = 2 setget set_str
export(int) var dexterity: int = 2 setget set_dex
export(int) var magic: int = 2 setget set_mag
export(int) var vitality: int = 2 setget set_vit

func _ready() -> void:
	current_weapon = weapons.get_child(0)
	_restore_previous_state()
	get_node("CollisionShape2D").disabled = false
	

func _restore_previous_state() -> void:
	self.hp = SavedData.hp
	self.level = SavedData.level
	self.strength = SavedData.strength
	self.dexterity = SavedData.dexterity
	self.magic = SavedData.magic
	self.vitality = SavedData.vitality


func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	current_weapon.move(mouse_direction)

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
	if not current_weapon.is_busy():
		if Input.is_action_just_pressed("ui_switch_weapon"):
			_switch_weapon()
	
	current_weapon.get_input()

func _switch_weapon() -> void:
	var previous_index: int = current_weapon_index
	
	if current_weapon_index == 1:
		current_weapon_index = 0
	else:
		current_weapon_index = 1
	
	if is_instance_valid(weapons.get_child(current_weapon_index)):
		current_weapon.hide()
		current_weapon = weapons.get_child(current_weapon_index)
		current_weapon.show()
	else:
		current_weapon_index = previous_index


func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false

func  pick_up_weapon(weapon: Node2D) -> void:
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	_drop_weapon()
	current_weapon = weapon
	current_weapon.set_stats()
	able_to_pickup = false
	pickup_timer.start()


func _drop_weapon() -> void:
	SavedData.weapons.remove(current_weapon.get_index() - 1)
	
	var weapon_to_drop: Node2D = current_weapon
	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.set_owner(get_parent())
	yield(weapon_to_drop.tween, "tree_entered")
	weapon_to_drop.show()
	weapon_to_drop.dropped()
	
	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.interpolate_pos(position, position + throw_dir * 20)


func set_lvl(new_lvl: int) -> void:
	level = new_lvl

func set_str(new_str: int) -> void:
	strength = new_str

func set_dex(new_dex: int) -> void:
	dexterity = new_dex

func set_mag(new_mag: int) -> void:
	magic = new_mag

func set_vit(new_vit: int) -> void:
	vitality = new_vit


func _on_PickupTimer_timeout():
	able_to_pickup = true
