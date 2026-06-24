extends Area2D
## Dropped after clearing a room — restores a chunk of flame energy.

@export var restore_amount: float = 25.0

var _collected: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if animated_sprite:
		animated_sprite.play("float")


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	if body.has_node("FlameSystem"):
		body.get_node("FlameSystem").restore_energy(restore_amount)
	queue_free()
