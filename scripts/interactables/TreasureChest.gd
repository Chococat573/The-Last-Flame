extends Node2D

@export var flame_restore_amount: float = 20.0
@export var health_restore_amount: float = 15.0

var _opened: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_label: Label = $InteractLabel


func _ready() -> void:
	interact_label.hide()


func interact(interactor: Node) -> void:
	if _opened:
		return
	_opened = true
	interact_label.hide()
	animated_sprite.play("open")

	if interactor.has_node("FlameSystem"):
		interactor.get_node("FlameSystem").restore_energy(flame_restore_amount)
	if interactor.has_node("PlayerHealth"):
		interactor.get_node("PlayerHealth").heal(health_restore_amount)

	EventBus.treasure_collected.emit({
		"flame": flame_restore_amount,
		"health": health_restore_amount,
	})


func _on_player_entered(_body: Node) -> void:
	if not _opened:
		interact_label.show()


func _on_player_exited(_body: Node) -> void:
	interact_label.hide()
