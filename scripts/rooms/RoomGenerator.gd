extends Node
## Procedurally generates room layouts using tile maps and placement rules.

enum RoomType { NORMAL, ELITE, TREASURE, BOSS, START }

@export var room_width: int = 24
@export var room_height: int = 16
@export var tile_size: int = 16

@onready var tile_map: TileMap = $TileMap

# Tile source IDs (configure in Godot editor to match your tileset)
const TILE_FLOOR := Vector2i(0, 0)
const TILE_WALL := Vector2i(1, 0)
const TILE_OBSTACLE := Vector2i(2, 0)

var _rng := RandomNumberGenerator.new()

@export_group("Enemy Spawning")
@export var min_enemies: int = 3
@export var max_enemies: int = 7
@export var obstacle_density: float = 0.04  # fraction of floor tiles that become obstacles

signal room_generated(enemy_spawns: Array[Vector2], treasure_spawns: Array[Vector2])


func generate(room_type: RoomType, seed: int = -1) -> void:
	if seed >= 0:
		_rng.seed = seed
	else:
		_rng.randomize()

	tile_map.clear()
	_fill_floor()
	_place_walls()

	var enemy_spawns: Array[Vector2] = []
	var treasure_spawns: Array[Vector2] = []

	match room_type:
		RoomType.NORMAL:
			_place_obstacles()
			enemy_spawns = _generate_enemy_spawns(min_enemies, max_enemies)
		RoomType.ELITE:
			_place_obstacles()
			enemy_spawns = _generate_enemy_spawns(max_enemies, max_enemies + 3)
		RoomType.TREASURE:
			treasure_spawns = _generate_treasure_spawns(1, 3)
		RoomType.BOSS:
			enemy_spawns = [_center_position()]
		RoomType.START:
			pass  # No enemies in start room

	room_generated.emit(enemy_spawns, treasure_spawns)


func _fill_floor() -> void:
	for x in range(1, room_width - 1):
		for y in range(1, room_height - 1):
			tile_map.set_cell(0, Vector2i(x, y), 0, TILE_FLOOR)


func _place_walls() -> void:
	for x in room_width:
		tile_map.set_cell(0, Vector2i(x, 0), 0, TILE_WALL)
		tile_map.set_cell(0, Vector2i(x, room_height - 1), 0, TILE_WALL)
	for y in room_height:
		tile_map.set_cell(0, Vector2i(0, y), 0, TILE_WALL)
		tile_map.set_cell(0, Vector2i(room_width - 1, y), 0, TILE_WALL)
	# Door openings
	tile_map.set_cell(0, Vector2i(room_width / 2, 0), 0, TILE_FLOOR)
	tile_map.set_cell(0, Vector2i(room_width / 2, room_height - 1), 0, TILE_FLOOR)
	tile_map.set_cell(0, Vector2i(0, room_height / 2), 0, TILE_FLOOR)
	tile_map.set_cell(0, Vector2i(room_width - 1, room_height / 2), 0, TILE_FLOOR)


func _place_obstacles() -> void:
	var floor_tiles := _get_inner_tiles()
	var obstacle_count := int(floor_tiles.size() * obstacle_density)
	floor_tiles.shuffle()
	for i in obstacle_count:
		var cell: Vector2i = floor_tiles[i]
		if _is_near_center(cell):
			continue
		tile_map.set_cell(0, cell, 0, TILE_OBSTACLE)


func _generate_enemy_spawns(min_count: int, max_count: int) -> Array[Vector2]:
	var spawns: Array[Vector2] = []
	var count := _rng.randi_range(min_count, max_count)
	var floor_tiles := _get_inner_tiles()
	floor_tiles.shuffle()
	for i in min(count, floor_tiles.size()):
		var cell: Vector2i = floor_tiles[i]
		if _is_near_center(cell):
			continue
		spawns.append(tile_map.map_to_local(cell))
	return spawns


func _generate_treasure_spawns(min_count: int, max_count: int) -> Array[Vector2]:
	var spawns: Array[Vector2] = []
	var count := _rng.randi_range(min_count, max_count)
	var floor_tiles := _get_inner_tiles()
	floor_tiles.shuffle()
	for i in min(count, floor_tiles.size()):
		spawns.append(tile_map.map_to_local(floor_tiles[i]))
	return spawns


func _get_inner_tiles() -> Array:
	var tiles := []
	for x in range(2, room_width - 2):
		for y in range(2, room_height - 2):
			tiles.append(Vector2i(x, y))
	return tiles


func _is_near_center(cell: Vector2i) -> bool:
	var cx := room_width / 2
	var cy := room_height / 2
	return abs(cell.x - cx) < 3 and abs(cell.y - cy) < 3


func _center_position() -> Vector2:
	return tile_map.map_to_local(Vector2i(room_width / 2, room_height / 2))
