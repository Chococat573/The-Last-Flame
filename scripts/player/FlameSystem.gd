extends Node
## The flame is the player's only light source, mana pool, and survival resource.
## Energy decays over time and is consumed by abilities. Reaching zero = death.

const BASE_MAX_ENERGY := 100.0
const BASE_DECAY_RATE := 3.0     # energy lost per second
const BASE_LIGHT_RADIUS := 180.0
const MIN_LIGHT_RADIUS := 40.0

var max_energy: float:
	get: return BASE_MAX_ENERGY + RunData.bonus_flame_max_energy
var current_energy: float

var _decay_rate: float:
	get: return maxf(0.5, BASE_DECAY_RATE - RunData.bonus_flame_decay_reduction)

@onready var light: PointLight2D = $PointLight2D


func _ready() -> void:
	current_energy = max_energy
	_update_light()
	EventBus.flame_energy_changed.emit(current_energy, max_energy)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_decay(delta)
	_update_light()


func _decay(delta: float) -> void:
	consume_energy(_decay_rate * delta)


func consume_energy(amount: float) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	current_energy = maxf(current_energy, 0.0)
	EventBus.flame_energy_changed.emit(current_energy, max_energy)
	if current_energy <= 0.0:
		EventBus.flame_extinguished.emit()
		EventBus.player_died.emit()
	return true


func restore_energy(amount: float) -> void:
	current_energy = minf(current_energy + amount, max_energy)
	EventBus.flame_energy_changed.emit(current_energy, max_energy)
	EventBus.flame_restored.emit(amount)


func has_energy(amount: float) -> bool:
	return current_energy >= amount


func get_energy_ratio() -> float:
	return current_energy / max_energy


func _update_light() -> void:
	if not light:
		return
	var base_radius := BASE_LIGHT_RADIUS + RunData.bonus_vision_radius
	var energy_ratio := get_energy_ratio()
	var target_radius := lerpf(MIN_LIGHT_RADIUS, base_radius, energy_ratio)
	light.texture_scale = target_radius / 100.0
	# Flicker subtly when low on energy
	if energy_ratio < 0.25:
		light.texture_scale += randf_range(-0.02, 0.02)
	# Colour shifts from warm white -> deep orange as energy drains
	light.color = Color(1.0, lerpf(0.4, 1.0, energy_ratio), lerpf(0.1, 0.8, energy_ratio))
