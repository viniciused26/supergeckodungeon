extends Node2D

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://characters/enemies/SpawnExplosion.tscn")

const ENEMY_SCENES: Dictionary = {
	"SMALL_ZOMBIE": preload("res://characters/enemies/small_zombie/SmallZombie.tscn"),
	"MASKED_ORC": preload("res://characters/enemies/masked_orc/MaskedOrc.tscn")
}

const WEAPON_SCENES : Dictionary = {
	"SWORD": preload("res://weapons/sword/Sword.tscn"),
	"MORNINGSTAR": preload("res://weapons/morningstar/MorningStar.tscn"),
	"GOLDEN_SWORD": preload("res://weapons/golden_sword/GoldenSword.tscn"),
	"CROSSBOW": preload("res://weapons/crossbow/Crossbow.tscn")
}

var num_enemies: int
var num_weapons: int

onready var tilemap: TileMap = get_node("TileMap2")
onready var entrance: Node2D = get_node("Entrance")
onready var door_container: Node2D = get_node("Doors")
onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
onready var weapon_positions_container: Node2D = get_node("WeaponSpawners")
onready var weapon_container: Node2D = get_node("WeaponContainer")
onready var player_detector: Area2D = get_node("PlayerDetector")
onready var closing_doors: StaticBody2D = get_node("ClosingDoors")

func _ready() -> void:
	closing_doors.get_node("CollisionShape2D").disabled = true
	num_enemies = enemy_positions_container.get_child_count()
	num_weapons = weapon_positions_container.get_child_count()
	_spawn_weapons()

func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		_open_doors()

func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()
		

func _close_entrance() -> void:
	for entry_position in entrance.get_children():
		tilemap.set_cellv(tilemap.world_to_map(entry_position.position), 1)
		tilemap.set_cellv(tilemap.world_to_map(entry_position.position) + Vector2.DOWN, 4)

func _spawn_weapons() -> void:
	for weapon_position in weapon_positions_container.get_children():
		var weapon: Node2D
		if randi() % 2 == 0:
			weapon = WEAPON_SCENES.CROSSBOW.instance()
		else:
			weapon = WEAPON_SCENES.GOLDEN_SWORD.instance()
		
		
		weapon.on_floor = true
		
		weapon_container.position = weapon_position.position
		weapon_container.add_child(weapon)
		weapon.global_position = weapon_container.position
		

func _spawn_enemies() -> void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy: KinematicBody2D
		
		if randi() % 2 == 0:
			enemy = ENEMY_SCENES.SMALL_ZOMBIE.instance()
		else:
			enemy = ENEMY_SCENES.MASKED_ORC.instance()
		
		var __ = enemy.connect("tree_exited", self, "_on_enemy_killed") 
		enemy.position = enemy_position.position
		call_deferred("add_child", enemy)
		
		var spawn_explosion: AnimatedSprite = SPAWN_EXPLOSION_SCENE.instance()
		spawn_explosion.position = enemy_position.position
		call_deferred("add_child", spawn_explosion)


func _on_PlayerDetector_body_entered(_body: KinematicBody2D) -> void:
	player_detector.queue_free()
	if num_enemies > 0:
		closing_doors.get_node("AnimationPlayer").play("closing")
		_spawn_enemies()
	else:
		_open_doors()
