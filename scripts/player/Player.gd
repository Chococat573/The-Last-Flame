extends CharacterBody2D
## The player character. Handles movement, sprinting, and interaction.

const BASE_SPEED := 120.0
const SPRINT_SPEED := 200.0
const SPRINT_DURATION := 1.5
const SPRINT_COOLDOWN := 3.0

var _speed: float = BASE_SPEED
var _sprint_timer: float = 0.0
var _sprint_cooldown_timer: float = 0.0
var _is_sprinting: bool = false
var _facing_direction: Vector2 = Vector2.RIGHT

@onready var flame_system: Node = $FlameSystem
@onready var combat: Node = $PlayerCombat
@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	EventBus.player_died.connect(_on_died)
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_handle_sprint(delta)
	_handle_movement()
	_handle_interaction()
	move_and_slide()


func _handle_movement() -> void:
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	var effective_speed := SPRINT_SPEED if _is_sprinting else BASE_SPEED
	effective_speed += RunData.bonus_move_speed

	velocity = direction * effective_speed

	if direction != Vector2.ZERO:
		_facing_direction = direction
		_play_move_animation(direction)
	else:
		_play_idle_animation()


func _handle_sprint(delta: float) -> void:
	if _sprint_cooldown_timer > 0.0:
		_sprint_cooldown_timer -= delta

	if _is_sprinting:
		_sprint_timer -= delta
		if _sprint_timer <= 0.0:
			_is_sprinting = false
			_sprint_cooldown_timer = SPRINT_COOLDOWN

	if Input.is_action_just_pressed("sprint") and _sprint_cooldown_timer <= 0.0 and not _is_sprinting:
		_is_sprinting = true
		_sprint_timer = SPRINT_DURATION


func _handle_interaction() -> void:
	if not Input.is_action_just_pressed("interact"):
		return
	for body in interaction_area.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact(self)
			break
	for area in interaction_area.get_overlapping_areas():
		if area.has_method("interact"):
			area.interact(self)
			break


func _play_move_animation(direction: Vector2) -> void:
	if abs(direction.x) >= abs(direction.y):
		animated_sprite.flip_h = direction.x < 0
		animated_sprite.play("walk_side")
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	else:
		animated_sprite.play("walk_down")


func _play_idle_animation() -> void:
	animated_sprite.play("idle")


func get_facing_direction() -> Vector2:
	return _facing_direction


func get_sprint_cooldown_ratio() -> float:
	return 1.0 - (_sprint_cooldown_timer / SPRINT_COOLDOWN)


func _on_died() -> void:
	set_physics_process(false)
	animated_sprite.play("death")
