extends Node
## Holds all mutable state for the current run (resets each run).

var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 100

# Stat modifiers accumulated from upgrades
var bonus_max_health: float = 0.0
var bonus_damage: float = 0.0
var bonus_move_speed: float = 0.0
var bonus_flame_max_energy: float = 0.0
var bonus_flame_decay_reduction: float = 0.0
var bonus_vision_radius: float = 0.0

var active_passives: Array[Resource] = []
var collected_upgrades: Array[Resource] = []

var enemies_killed: int = 0
var rooms_cleared: int = 0
var run_time_seconds: float = 0.0


func reset() -> void:
	player_level = 1
	player_xp = 0
	xp_to_next_level = 100
	bonus_max_health = 0.0
	bonus_damage = 0.0
	bonus_move_speed = 0.0
	bonus_flame_max_energy = 0.0
	bonus_flame_decay_reduction = 0.0
	bonus_vision_radius = 0.0
	active_passives.clear()
	collected_upgrades.clear()
	enemies_killed = 0
	rooms_cleared = 0
	run_time_seconds = 0.0


func add_xp(amount: int) -> void:
	player_xp += amount
	while player_xp >= xp_to_next_level:
		player_xp -= xp_to_next_level
		_level_up()


func _level_up() -> void:
	player_level += 1
	xp_to_next_level = int(xp_to_next_level * 1.4)


func _process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		run_time_seconds += delta
