extends Navigation2D

const SPAWN_ROOMS: Array = [preload("res://rooms/spawnrooms/SpawnRoom1.tscn")]
const INTERMEDIATE_ROOMS: Array = [preload("res://rooms/enemyrooms/EnemyRoom1.tscn"), 
preload("res://rooms/enemyrooms/EnemyRoom2.tscn"),
preload("res://rooms/enemyrooms/EnemyRoom3.tscn")]
const END_ROOMS: Array = [preload("res://rooms/endrooms/EndRoom1.tscn")]

const TILE_SIZE: int = 16
const FLOOR_TILE_INDEX: int = 6
const RIGHT_WALL_TILE_INDEX: int = 24
const LEFT_WALL_TILE_INDEX: int = 23

export(int) var num_levels: int = 5

onready var player: KinematicBody2D = get_parent().get_node("Player")

func _ready() -> void:
	if player.level <= 5:
		num_levels = 5
	elif player.level <= 10:
		num_levels = 7
	elif player.level <= 15:
		num_levels = 9
	elif player.level <= 20:
		num_levels = 11
	_spawn_rooms()

func _spawn_rooms() -> void:
	var previous_room: Node2D
	
	for i in num_levels:
		var room: Node2D
		
		if i == 0:
			room = SPAWN_ROOMS[randi() % SPAWN_ROOMS.size()].instance()
			player.position = room.get_node("PlayerSpawnPos").position
		else:
			if i == num_levels - 1:
				room = END_ROOMS[randi() % END_ROOMS.size()].instance()
			else:
				room = INTERMEDIATE_ROOMS[randi() % INTERMEDIATE_ROOMS.size()].instance()
			
			var previous_room_tilemap: TileMap = previous_room.get_node("TileMap2")
			var previous_room_door: StaticBody2D = previous_room.get_node("Doors/Door")
			var exit_tile_pos: Vector2 = previous_room_tilemap.world_to_map(previous_room_door.position) + Vector2.UP
			
			var corridor_height: int = randi() % 7 + 3
			for y in corridor_height:
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(-2, -y), LEFT_WALL_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(-1, -y), FLOOR_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(0, -y), FLOOR_TILE_INDEX)
				previous_room_tilemap.set_cellv(exit_tile_pos + Vector2(1, -y), RIGHT_WALL_TILE_INDEX)
				
			var room_tilemap: TileMap = room.get_node("TileMap")
			room.position = previous_room_door.global_position + Vector2.UP * room_tilemap.get_used_rect().size.y * TILE_SIZE + Vector2.UP * (corridor_height) * TILE_SIZE + Vector2.LEFT * room_tilemap.world_to_map(room.get_node("Entrance/Position2D2").position).x * TILE_SIZE
			room.position -= Vector2(-1,0)
		
		add_child(room)
		previous_room = room
