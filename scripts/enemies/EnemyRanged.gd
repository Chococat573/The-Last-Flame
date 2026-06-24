extends "res://scripts/enemies/EnemyBase.gd"
## Ranged enemy — keeps its distance and fires projectiles.

@export var preferred_distance: float = 120.0

const PROJECTILE_SCENE := preload("res://scenes/combat/enemy_projectile.tscn")


func _state_chase(_delta: float) -> void:
	if not _player:
		_state = State.IDLE
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist > detection_range * 1.5:
		_state = State.IDLE
		return
	# Maintain preferred distance
	if dist < preferred_distance - 20.0:
		velocity = (global_position - _player.global_position).normalized() * base_speed
	elif dist > preferred_distance + 20.0:
		velocity = (_player.global_position - global_position).normalized() * base_speed
	else:
		velocity = Vector2.ZERO
		if _attack_timer <= 0.0:
			_perform_attack()
			_attack_timer = attack_cooldown
	if animated_sprite and velocity != Vector2.ZERO:
		animated_sprite.play("walk")


func _state_attack(_delta: float) -> void:
	_state_chase(_delta)


func _perform_attack() -> void:
	if not _player:
		return
	var projectile := PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	var direction := (_player.global_position - global_position).normalized()
	projectile.setup(direction, base_damage, "player")
	if animated_sprite:
		animated_sprite.play("attack")
