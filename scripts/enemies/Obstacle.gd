extends Area2D
## Static hazard (spikes, lava, etc.) — invulnerable, damages on contact.

@export var damage_per_second: float = 15.0
@export var damage_interval: float = 0.5

var _damage_timer: float = 0.0
var _bodies_inside: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if _bodies_inside.is_empty():
		return
	_damage_timer -= delta
	if _damage_timer <= 0.0:
		_damage_timer = damage_interval
		for body in _bodies_inside:
			if body.has_node("PlayerHealth"):
				body.get_node("PlayerHealth").take_damage(damage_per_second * damage_interval)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_bodies_inside.append(body)


func _on_body_exited(body: Node) -> void:
	_bodies_inside.erase(body)
