extends Node
## Manages the sequence of rooms within a floor, tracks enemy counts, and
## triggers room-cleared events.

@export var floor_index: int = 0

# Enemy scene pools per floor — populate in each floor's scene
@export var normal_enemy_scenes: Array[PackedScene] = []
@export var elite_enemy_scenes: Array[PackedScene] = []
@export var boss_scene: PackedScene

@onready var room_generator: Node = $RoomGenerator
@onready var enemy_container: Node = $Enemies
@onready var treasure_container: Node = $Treasures

const TREASURE_SCENE := preload("res://scenes/interactables/treasure_chest.tscn")
const FLAME_PICKUP_SCENE := preload("res://scenes/interactables/flame_pickup.tscn")

var _current_room_type: int
var _active_enemies: int = 0
var _room_index: int = 0

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	load_room(0)


func load_room(room_index: int) -> void:
	_room_index = room_index
	_clear_room()

	var room_type: int
	if room_index == 0:
		room_type = RoomGenerator.RoomType.START
	elif room_index == GameManager.BOSS_ROOM_INDEX:
		room_type = RoomGenerator.RoomType.BOSS
	elif room_index % 3 == 2:
		room_type = RoomGenerator.RoomType.TREASURE
	elif room_index % 4 == 3:
		room_type = RoomGenerator.RoomType.ELITE
	else:
		room_type = RoomGenerator.RoomType.NORMAL

	_current_room_type = room_type
	_rng.randomize()
	room_generator.generate(room_type, _rng.randi())
	EventBus.room_entered.emit(self)


func _on_room_generated(enemy_spawns: Array[Vector2], treasure_spawns: Array[Vector2]) -> void:
	_active_enemies = 0

	match _current_room_type:
		RoomGenerator.RoomType.BOSS:
			_spawn_boss(enemy_spawns[0] if not enemy_spawns.is_empty() else Vector2.ZERO)
		RoomGenerator.RoomType.NORMAL, RoomGenerator.RoomType.ELITE:
			_spawn_enemies(enemy_spawns)
		RoomGenerator.RoomType.TREASURE:
			_spawn_treasures(treasure_spawns)
			_active_enemies = 0  # No enemies — room is immediately clearable
			EventBus.room_cleared.emit()
			RunData.rooms_cleared += 1


func _spawn_enemies(spawns: Array[Vector2]) -> void:
	var pool := normal_enemy_scenes if _current_room_type == RoomGenerator.RoomType.NORMAL else elite_enemy_scenes
	if pool.is_empty():
		return
	for spawn_pos in spawns:
		var scene: PackedScene = pool[_rng.randi() % pool.size()]
		var enemy := scene.instantiate()
		enemy_container.add_child(enemy)
		enemy.global_position = spawn_pos
		_active_enemies += 1


func _spawn_boss(spawn_pos: Vector2) -> void:
	if not boss_scene:
		return
	var boss := boss_scene.instantiate()
	enemy_container.add_child(boss)
	boss.global_position = spawn_pos
	_active_enemies = 1


func _spawn_treasures(spawns: Array[Vector2]) -> void:
	for pos in spawns:
		var chest := TREASURE_SCENE.instantiate()
		treasure_container.add_child(chest)
		chest.global_position = pos


func _on_enemy_died(_enemy: Node, _position: Vector2) -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and _current_room_type != RoomGenerator.RoomType.TREASURE:
		_on_room_cleared()


func _on_room_cleared() -> void:
	RunData.rooms_cleared += 1
	_spawn_flame_pickup()
	EventBus.room_cleared.emit()


func _spawn_flame_pickup() -> void:
	var pickup := FLAME_PICKUP_SCENE.instantiate()
	add_child(pickup)
	pickup.global_position = room_generator.get_node("TileMap").map_to_local(
		Vector2i(room_generator.room_width / 2, room_generator.room_height / 2)
	)


func _clear_room() -> void:
	for child in enemy_container.get_children():
		child.queue_free()
	for child in treasure_container.get_children():
		child.queue_free()
