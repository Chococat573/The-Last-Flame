extends CharacterBody2D
## Base class for all enemies. Subclass this for specific enemy types.

enum State { IDLE, CHASE, ATTACK, STUNNED, DEAD }

@export var base_health: float = 40.0
@export var base_damage: float = 10.0
@export var base_speed: float = 60.0
@export var xp_reward: int = 10
@export var detection_range: float = 200.0
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.5

var current_health: float
var max_health: float
var _state: State = State.IDLE
var _attack_timer: float = 0.0
var _stun_timer: float = 0.0

var _player: CharacterBody2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	var difficulty := GameManager.get_difficulty_multiplier()
	max_health = base_health * difficulty
	base_damage = base_damage * difficulty
	current_health = max_health
	add_to_group("enemy")
	_find_player()
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return

	_update_attack_timer(delta)

	match _state:
		State.IDLE:
			_state_idle(delta)
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)
		State.STUNNED:
			_state_stunned(delta)

	move_and_slide()


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]


func _update_attack_timer(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)


func _state_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	if animated_sprite:
		animated_sprite.play("idle")
	if _player and global_position.distance_to(_player.global_position) <= detection_range:
		_state = State.CHASE


func _state_chase(_delta: float) -> void:
	if not _player:
		_state = State.IDLE
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist > detection_range * 1.5:
		_state = State.IDLE
		return
	if dist <= attack_range:
		_state = State.ATTACK
		velocity = Vector2.ZERO
		return
	velocity = ((_player.global_position - global_position).normalized()) * base_speed
	if animated_sprite:
		animated_sprite.play("walk")


func _state_attack(_delta: float) -> void:
	velocity = Vector2.ZERO
	if not _player:
		_state = State.IDLE
		return
	if global_position.distance_to(_player.global_position) > attack_range * 1.2:
		_state = State.CHASE
		return
	if _attack_timer <= 0.0:
		_perform_attack()
		_attack_timer = attack_cooldown


func _state_stunned(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	_stun_timer -= delta
	if _stun_timer <= 0.0:
		_state = State.CHASE


## Override in subclasses for custom attack behaviour.
func _perform_attack() -> void:
	if _player and _player.has_node("PlayerHealth"):
		_player.get_node("PlayerHealth").take_damage(base_damage)
	if animated_sprite:
		animated_sprite.play("attack")


func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _state == State.DEAD:
		return
	current_health -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if health_bar:
		health_bar.value = current_health
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * 150.0
		_stun_timer = 0.2
		_state = State.STUNNED
	if current_health <= 0.0:
		_die()


func _die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	RunData.add_xp(xp_reward)
	RunData.enemies_killed += 1
	EventBus.enemy_died.emit(self, global_position)
	if animated_sprite:
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	queue_free()
