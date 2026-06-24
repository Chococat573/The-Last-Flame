extends Node
## Manages player health, damage, and death.

const BASE_MAX_HEALTH := 100.0
const INVINCIBILITY_DURATION := 0.6

var max_health: float:
	get: return BASE_MAX_HEALTH + RunData.bonus_max_health
var current_health: float

var _invincible: bool = false
var _invincible_timer: float = 0.0


func _ready() -> void:
	current_health = max_health
	EventBus.player_health_changed.emit(current_health, max_health)


func _process(delta: float) -> void:
	if _invincible:
		_invincible_timer -= delta
		if _invincible_timer <= 0.0:
			_invincible = false


func take_damage(amount: float) -> void:
	if _invincible:
		return
	current_health -= amount
	current_health = maxf(current_health, 0.0)
	EventBus.player_damaged.emit(amount)
	EventBus.player_health_changed.emit(current_health, max_health)
	_invincible = true
	_invincible_timer = INVINCIBILITY_DURATION
	if current_health <= 0.0:
		EventBus.player_died.emit()


func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
	EventBus.player_health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0.0
