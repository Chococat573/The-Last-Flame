extends "res://scripts/enemies/EnemyBase.gd"
## Base class for all bosses. Bosses have multiple phases and complex attack patterns.

const BOSS_HEALTH_MULTIPLIER := 12.0
const BOSS_DAMAGE_MULTIPLIER := 8.0

@export var floor_index: int = 0
@export var phase_thresholds: Array[float] = [0.66, 0.33]  # health % triggers

var current_phase: int = 0
var _phase_count: int


func _ready() -> void:
	super._ready()
	base_health *= BOSS_HEALTH_MULTIPLIER
	base_damage *= BOSS_DAMAGE_MULTIPLIER
	max_health = base_health
	current_health = max_health
	_phase_count = phase_thresholds.size() + 1
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health


func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	super.take_damage(amount, knockback_dir)
	_check_phase_transition()


func _check_phase_transition() -> void:
	var health_ratio := current_health / max_health
	for i in phase_thresholds.size():
		if current_phase == i and health_ratio <= phase_thresholds[i]:
			current_phase = i + 1
			_on_phase_changed(current_phase)
			EventBus.boss_phase_changed.emit(self, current_phase)
			break


## Override in subclasses to trigger phase-specific behaviour.
func _on_phase_changed(phase: int) -> void:
	pass


func _die() -> void:
	EventBus.boss_died.emit(self, floor_index)
	super._die()
