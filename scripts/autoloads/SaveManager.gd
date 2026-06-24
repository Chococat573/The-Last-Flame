extends Node
## Handles persistent save data (meta-progression between runs).

const SAVE_PATH := "user://save_data.json"

var unlocked_abilities: Array[String] = []
var unlocked_passives: Array[String] = []
var total_runs: int = 0
var total_wins: int = 0
var highest_floor_reached: int = 0
var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"colorblind_mode": false,
	"bindings": {},
}


func _ready() -> void:
	load_data()


func save_run_complete() -> void:
	total_wins += 1
	total_runs += 1
	save_data()


func save_run_failed(floor_reached: int) -> void:
	total_runs += 1
	highest_floor_reached = max(highest_floor_reached, floor_reached)
	save_data()


func unlock_ability(ability_id: String) -> void:
	if ability_id not in unlocked_abilities:
		unlocked_abilities.append(ability_id)
		save_data()


func unlock_passive(passive_id: String) -> void:
	if passive_id not in unlocked_passives:
		unlocked_passives.append(passive_id)
		save_data()


func save_settings() -> void:
	save_data()


func save_data() -> void:
	var data := {
		"unlocked_abilities": unlocked_abilities,
		"unlocked_passives": unlocked_passives,
		"total_runs": total_runs,
		"total_wins": total_wins,
		"highest_floor_reached": highest_floor_reached,
		"settings": settings,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var result: Variant = JSON.parse_string(file.get_as_text())
	if result is Dictionary:
		unlocked_abilities = result.get("unlocked_abilities", [])
		unlocked_passives = result.get("unlocked_passives", [])
		total_runs = result.get("total_runs", 0)
		total_wins = result.get("total_wins", 0)
		highest_floor_reached = result.get("highest_floor_reached", 0)
		settings.merge(result.get("settings", {}), true)
		_apply_settings()


func _apply_settings() -> void:
	AudioManager.set_volume(AudioManager.BUS_MASTER, settings.get("master_volume", 1.0))
	AudioManager.set_volume(AudioManager.BUS_MUSIC, settings.get("music_volume", 0.8))
	AudioManager.set_volume(AudioManager.BUS_SFX, settings.get("sfx_volume", 1.0))
