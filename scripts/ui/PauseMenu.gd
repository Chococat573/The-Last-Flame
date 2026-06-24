extends CanvasLayer

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var colorblind_toggle: CheckButton = %ColorblindToggle
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	EventBus.pause_toggled.connect(_on_pause_toggled)
	resume_button.pressed.connect(GameManager.toggle_pause)
	quit_button.pressed.connect(_on_quit)
	master_slider.value = SaveManager.settings.get("master_volume", 1.0)
	music_slider.value = SaveManager.settings.get("music_volume", 0.8)
	sfx_slider.value = SaveManager.settings.get("sfx_volume", 1.0)
	colorblind_toggle.button_pressed = SaveManager.settings.get("colorblind_mode", false)
	master_slider.value_changed.connect(func(v): _update_volume(AudioManager.BUS_MASTER, "master_volume", v))
	music_slider.value_changed.connect(func(v): _update_volume(AudioManager.BUS_MUSIC, "music_volume", v))
	sfx_slider.value_changed.connect(func(v): _update_volume(AudioManager.BUS_SFX, "sfx_volume", v))
	colorblind_toggle.toggled.connect(_on_colorblind_toggled)
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_just_pressed("pause"):
		GameManager.toggle_pause()


func _on_pause_toggled(is_paused: bool) -> void:
	visible = is_paused


func _update_volume(bus: String, setting_key: String, value: float) -> void:
	AudioManager.set_volume(bus, value)
	SaveManager.settings[setting_key] = value
	SaveManager.save_settings()


func _on_colorblind_toggled(enabled: bool) -> void:
	SaveManager.settings["colorblind_mode"] = enabled
	SaveManager.save_settings()
	# Apply a shader or palette swap globally when implemented


func _on_quit() -> void:
	GameManager.current_state = GameManager.GameState.MAIN_MENU
	SaveManager.save_run_failed(GameManager.current_floor)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
