extends CanvasLayer
## Heads-up display showing flame energy, health, ability cooldowns, and level.

@onready var flame_bar: ProgressBar = %FlameBar
@onready var health_bar: ProgressBar = %HealthBar
@onready var flame_label: Label = %FlameLabel
@onready var health_label: Label = %HealthLabel
@onready var level_label: Label = %LevelLabel
@onready var floor_label: Label = %FloorLabel
@onready var ability_1_cooldown: TextureProgressBar = %Ability1Cooldown
@onready var ability_2_cooldown: TextureProgressBar = %Ability2Cooldown
@onready var sprint_bar: ProgressBar = %SprintBar

var _player: CharacterBody2D = null
const FLOOR_NAMES := ["The Ashen Forest", "Forgotten Ruins", "The Black Citadel"]


func _ready() -> void:
	EventBus.flame_energy_changed.connect(_on_flame_changed)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.floor_started.connect(_on_floor_started)


func _process(_delta: float) -> void:
	if not _player:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_player = players[0]
		return

	if _player.has_node("PlayerCombat"):
		var combat := _player.get_node("PlayerCombat")
		ability_1_cooldown.value = combat.get_ability_cooldown_ratio("flame_burst") * 100.0
		ability_2_cooldown.value = combat.get_ability_cooldown_ratio("fire_dash") * 100.0

	sprint_bar.value = _player.get_sprint_cooldown_ratio() * 100.0
	level_label.text = "Lv. %d" % RunData.player_level


func _on_flame_changed(current: float, maximum: float) -> void:
	flame_bar.max_value = maximum
	flame_bar.value = current
	flame_label.text = "%d / %d" % [int(current), int(maximum)]
	# Pulse bar red when low
	flame_bar.modulate = Color.RED if current / maximum < 0.25 else Color.WHITE


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [int(current), int(maximum)]


func _on_floor_started(floor_index: int) -> void:
	floor_label.text = FLOOR_NAMES[clampi(floor_index, 0, FLOOR_NAMES.size() - 1)]
