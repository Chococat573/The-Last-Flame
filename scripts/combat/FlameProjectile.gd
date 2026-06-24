extends Area2D
## Projectile fired by the player's flame abilities.

const SPEED := 280.0
const LIFETIME := 2.0

var _direction: Vector2
var _damage: float
var _target_group: String
var _lifetime: float = LIFETIME


func setup(direction: Vector2, damage: float, target_group: String) -> void:
	_direction = direction
	_damage = damage
	_target_group = target_group
	rotation = _direction.angle()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += _direction * SPEED * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(_target_group):
		if body.has_method("take_damage"):
			body.take_damage(_damage, _direction)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		queue_free()
