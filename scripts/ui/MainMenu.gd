extends Control

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var stats_label: Label = %StatsLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(get_tree().quit)
	stats_label.text = "Runs: %d   Wins: %d   Best Floor: %d" % [
		SaveManager.total_runs,
		SaveManager.total_wins,
		SaveManager.highest_floor_reached + 1,
	]


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().process_frame
	GameManager.start_run()
