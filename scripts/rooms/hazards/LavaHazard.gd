extends Node2D
## Black Citadel floor hazard — flowing lava that damages players on contact.

@export var damage_per_second: float = 20.0

@onready var lava_area: Area2D = $LavaArea

var _bodies_inside: Array[Node] = []
var _damage_timer: float = 0.0
const TICK_INTERVAL := 0.5


func _ready() -> void:
	lava_area.body_entered.connect(_on_body_entered)
	lava_area.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if _bodies_inside.is_empty():
		return
	_damage_timer -= delta
	if _damage_timer <= 0.0:
		_damage_timer = TICK_INTERVAL
		for body in _bodies_inside:
			if body.has_node("PlayerHealth"):
				body.get_node("PlayerHealth").take_damage(damage_per_second * TICK_INTERVAL)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_bodies_inside.append(body)


func _on_body_exited(body: Node) -> void:
	_bodies_inside.erase(body)
