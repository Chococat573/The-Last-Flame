extends "res://scripts/enemies/BossBase.gd"
## Floor 1 boss – The Ashen Warden.
## Phase 1: Charges at player.
## Phase 2: Adds homing embers.
## Phase 3: Rain hazard intensifies, spawns adds.

const EMBER_PROJECTILE := preload("res://scenes/combat/enemy_projectile.tscn")
const CHARGER_ENEMY := preload("res://scenes/enemies/charger.tscn")

var _charge_target: Vector2
var _is_charging: bool = false
var _charge_speed := 280.0
var _volley_timer: float = 0.0


func _ready() -> void:
	floor_index = 0
	phase_thresholds = [0.66, 0.33]
	super._ready()


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return
	_update_attack_timer(delta)
	_volley_timer = maxf(_volley_timer - delta, 0.0)

	if current_phase >= 1:
		_handle_ember_volley()

	if _is_charging:
		_continue_charge(delta)
		return
	super._physics_process(delta)


func _perform_attack() -> void:
	if not _player:
		return
	_charge_target = _player.global_position
	_is_charging = true
	if animated_sprite:
		animated_sprite.play("charge")


func _continue_charge(delta: float) -> void:
	var dir := (_charge_target - global_position).normalized()
	velocity = dir * _charge_speed
	move_and_slide()
	if global_position.distance_to(_charge_target) < 16.0:
		_is_charging = false
		velocity = Vector2.ZERO
		_state = State.ATTACK
		# Damage any player in proximity
		if _player and global_position.distance_to(_player.global_position) < 40.0:
			_player.get_node("PlayerHealth").take_damage(base_damage * 1.5)


func _handle_ember_volley() -> void:
	if _volley_timer > 0.0:
		return
	_volley_timer = 3.0 - (current_phase * 0.5)
	var count := 4 + current_phase * 2
	for i in count:
		var angle := (TAU / count) * i
		var projectile := EMBER_PROJECTILE.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position
		projectile.setup(Vector2.from_angle(angle), base_damage * 0.5, "player")


func _on_phase_changed(phase: int) -> void:
	match phase:
		1:
			_charge_speed = 350.0
		2:
			_charge_speed = 400.0
			# Spawn two minions
			for i in 2:
				var add := CHARGER_ENEMY.instantiate()
				get_tree().current_scene.add_child(add)
				add.global_position = global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))
