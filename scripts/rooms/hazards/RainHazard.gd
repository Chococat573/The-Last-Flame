extends Node2D
## Ashen Forest floor hazard — rain that accelerates flame decay.

@export var extra_decay_per_second: float = 2.0
@export var is_active: bool = false

@onready var particles: GPUParticles2D = $RainParticles
@onready var activation_timer: Timer = $ActivationTimer

var _flame_system: Node = null


func _ready() -> void:
	activation_timer.timeout.connect(_activate)
	activation_timer.start(randf_range(5.0, 15.0))


func _activate() -> void:
	is_active = true
	if particles:
		particles.emitting = true
	activation_timer.start(randf_range(8.0, 20.0))
	activation_timer.timeout.disconnect(_activate)
	activation_timer.timeout.connect(_deactivate)


func _deactivate() -> void:
	is_active = false
	if particles:
		particles.emitting = false
	activation_timer.start(randf_range(5.0, 15.0))
	activation_timer.timeout.disconnect(_deactivate)
	activation_timer.timeout.connect(_activate)


func _process(delta: float) -> void:
	if not is_active:
		return
	if not _flame_system:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_flame_system = players[0].get_node_or_null("FlameSystem")
	if _flame_system:
		_flame_system.consume_energy(extra_decay_per_second * delta)
