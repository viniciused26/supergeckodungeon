extends CanvasLayer

const MIN_HEALTH: int = 21

onready var player: KinematicBody2D = get_parent().get_node("Player")
onready var health_bar: TextureProgress = get_node("HealthBar")
onready var health_bar_tween: Tween = get_node("HealthBar/Tween")
onready var sec_wpn: TextureRect = get_node("SecondaryWeapon")

var max_hp: int

func _ready() -> void:
	max_hp = SavedData.max_hp
	_update_health_bar(100)

func _update_health_bar(new_value: int) -> void:
	var __ = health_bar_tween.interpolate_property(health_bar, "value", health_bar.value, new_value, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
	__ = health_bar_tween.start()

func _on_Player_hp_changed(new_hp):
	var new_health: int = int((100 - MIN_HEALTH) * float(new_hp) / max_hp) + MIN_HEALTH
	print("new_health: ", new_health)
	_update_health_bar(new_health)



func _on_Player_switch_weapon(new_texture: Texture) -> void:
	sec_wpn.set_texture(new_texture)
	pass # Replace with function body.
