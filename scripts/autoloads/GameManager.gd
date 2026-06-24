extends Node
## Manages overall game state: floors, rooms, transitions, and difficulty scaling.

enum GameState { MAIN_MENU, PLAYING, PAUSED, UPGRADE_SCREEN, GAME_OVER, RUN_COMPLETE }

const FLOOR_SCENES: Dictionary = {
	0: "res://scenes/floors/ashen_forest.tscn",
	1: "res://scenes/floors/forgotten_ruins.tscn",
	2: "res://scenes/floors/black_citadel.tscn",
}

const ROOMS_PER_FLOOR := 8
const BOSS_ROOM_INDEX := 7

var current_state: GameState = GameState.MAIN_MENU
var current_floor: int = 0
var current_room: int = 0
var difficulty_multiplier: float = 1.0

var _current_floor_node: Node = null


func _ready() -> void:
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.boss_died.connect(_on_boss_died)
	EventBus.player_died.connect(_on_player_died)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)


func start_run() -> void:
	current_floor = 0
	current_room = 0
	difficulty_multiplier = 1.0
	RunData.reset()
	_load_floor(current_floor)
	EventBus.game_started.emit()


func _load_floor(floor_index: int) -> void:
	if _current_floor_node:
		_current_floor_node.queue_free()

	var path: String = FLOOR_SCENES.get(floor_index, FLOOR_SCENES[0])
	var floor_scene: PackedScene = load(path)
	_current_floor_node = floor_scene.instantiate()
	get_tree().current_scene.add_child(_current_floor_node)
	current_state = GameState.PLAYING
	EventBus.floor_started.emit(floor_index)


func _on_room_cleared() -> void:
	current_room += 1
	if current_room >= ROOMS_PER_FLOOR:
		return
	if current_room == BOSS_ROOM_INDEX - 1:
		EventBus.upgrade_offered.emit(UpgradeSystem.generate_upgrade_choices())
		current_state = GameState.UPGRADE_SCREEN
	else:
		_load_next_room()


func _load_next_room() -> void:
	if _current_floor_node and _current_floor_node.has_method("load_room"):
		_current_floor_node.load_room(current_room)


func _on_boss_died(_boss: Node, floor_index: int) -> void:
	if floor_index >= 2:
		current_state = GameState.RUN_COMPLETE
		EventBus.run_completed.emit()
		SaveManager.save_run_complete()
	else:
		current_floor += 1
		current_room = 0
		difficulty_multiplier += 0.3
		EventBus.upgrade_offered.emit(UpgradeSystem.generate_upgrade_choices())
		current_state = GameState.UPGRADE_SCREEN
		EventBus.floor_completed.emit(floor_index)


func _on_player_died() -> void:
	current_state = GameState.GAME_OVER
	EventBus.game_over.emit()


func _on_upgrade_selected(_upgrade: Resource) -> void:
	if current_state == GameState.UPGRADE_SCREEN:
		current_state = GameState.PLAYING
		if current_room == BOSS_ROOM_INDEX:
			_load_floor(current_floor)
		else:
			_load_next_room()


func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		EventBus.pause_toggled.emit(true)
	elif current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		EventBus.pause_toggled.emit(false)


func get_difficulty_multiplier() -> float:
	return difficulty_multiplier + (RunData.player_level * 0.05)
