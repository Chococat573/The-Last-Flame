extends Node
## Central signal bus for decoupled communication between systems.

# Player signals
signal player_health_changed(current: float, maximum: float)
signal player_died()
signal player_damaged(amount: float)

# Flame signals
signal flame_energy_changed(current: float, maximum: float)
signal flame_extinguished()
signal flame_restored(amount: float)

# Combat signals
signal enemy_died(enemy: Node, position: Vector2)
signal enemy_damaged(enemy: Node, amount: float)
signal boss_died(boss: Node, floor_index: int)
signal boss_phase_changed(boss: Node, phase: int)

# Room / floor signals
signal room_cleared()
signal room_entered(room: Node)
signal floor_completed(floor_index: int)
signal floor_started(floor_index: int)

# Upgrade signals
signal upgrade_selected(upgrade: Resource)
signal upgrade_offered(upgrades: Array)

# Game state signals
signal game_started()
signal game_over()
signal run_completed()
signal pause_toggled(is_paused: bool)

# Treasure / interaction signals
signal treasure_collected(data: Dictionary)
signal interactable_activated(interactable: Node)
