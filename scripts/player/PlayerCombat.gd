extends Node
## Handles player attacks and flame-based abilities.

const BASE_DAMAGE := 20.0
const ATTACK_COOLDOWN := 0.4
const ATTACK_RANGE := 48.0

# Ability mana costs (flame energy)
const ABILITY_COSTS: Dictionary = {
	"flame_burst": 15.0,
	"fire_dash": 20.0,
}
const ABILITY_COOLDOWNS: Dictionary = {
	"flame_burst": 2.0,
	"fire_dash": 4.0,
}

var _attack_timer: float = 0.0
var _ability_timers: Dictionary = {"flame_burst": 0.0, "fire_dash": 0.0}

@onready var _player: CharacterBody2D = get_parent()
@onready var _flame: Node = get_parent().get_node("FlameSystem")
@onready var _attack_area: Area2D = $AttackArea
@onready var _projectile_spawn: Marker2D = $ProjectileSpawn

const FLAME_PROJECTILE := preload("res://scenes/combat/flame_projectile.tscn")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)
	for key in _ability_timers:
		_ability_timers[key] = maxf(_ability_timers[key] - delta, 0.0)

	if Input.is_action_just_pressed("attack"):
		_melee_attack()

	if Input.is_action_just_pressed("ability_1"):
		_use_ability("flame_burst")

	if Input.is_action_just_pressed("ability_2"):
		_use_ability("fire_dash")


func _melee_attack() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = ATTACK_COOLDOWN
	var damage := BASE_DAMAGE + RunData.bonus_damage
	for body in _attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(damage, _player.get_facing_direction())


func _use_ability(ability_id: String) -> void:
	if _ability_timers.get(ability_id, 0.0) > 0.0:
		return
	var cost: float = ABILITY_COSTS.get(ability_id, 0.0)
	if not _flame.has_energy(cost):
		return
	_flame.consume_energy(cost)
	_ability_timers[ability_id] = ABILITY_COOLDOWNS.get(ability_id, 1.0)

	match ability_id:
		"flame_burst":
			_flame_burst()
		"fire_dash":
			_fire_dash()


func _flame_burst() -> void:
	# Spawn projectiles in 8 directions
	var directions := [
		Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
		Vector2(1, 1).normalized(), Vector2(-1, 1).normalized(),
		Vector2(1, -1).normalized(), Vector2(-1, -1).normalized(),
	]
	for dir in directions:
		var projectile := FLAME_PROJECTILE.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = _projectile_spawn.global_position
		projectile.setup(dir, BASE_DAMAGE + RunData.bonus_damage, "enemy")


func _fire_dash() -> void:
	# Teleport forward a short distance and deal damage to enemies at destination
	var dash_distance := 80.0
	var target_pos := _player.global_position + _player.get_facing_direction() * dash_distance
	_player.global_position = target_pos
	var damage := (BASE_DAMAGE + RunData.bonus_damage) * 1.5
	for body in _attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(damage, _player.get_facing_direction())


func get_ability_cooldown_ratio(ability_id: String) -> float:
	var max_cd: float = ABILITY_COOLDOWNS.get(ability_id, 1.0)
	return 1.0 - (_ability_timers.get(ability_id, 0.0) / max_cd)
