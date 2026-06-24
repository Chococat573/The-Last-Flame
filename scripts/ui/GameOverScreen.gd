extends CanvasLayer

@onready var floor_label: Label = %FloorLabel
@onready var kills_label: Label = %KillsLabel
@onready var time_label: Label = %TimeLabel
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

const FLOOR_NAMES := ["The Ashen Forest", "Forgotten Ruins", "The Black Citadel"]


func _ready() -> void:
	EventBus.game_over.connect(_show)
	EventBus.run_completed.connect(_show_victory)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	hide()


func _show() -> void:
	show()
	SaveManager.save_run_failed(GameManager.current_floor)
	_populate_stats("You have been consumed by the dark.")


func _show_victory() -> void:
	show()
	SaveManager.save_run_complete()
	_populate_stats("The flame endures!")


func _populate_stats(message: String) -> void:
	floor_label.text = message + "\nReached: " + FLOOR_NAMES[clampi(GameManager.current_floor, 0, 2)]
	kills_label.text = "Enemies slain: %d" % RunData.enemies_killed
	var minutes := int(RunData.run_time_seconds / 60)
	var seconds := int(fmod(RunData.run_time_seconds, 60))
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]


func _on_retry() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await get_tree().process_frame
	GameManager.start_run()


func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
