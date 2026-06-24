extends Node
## Manages upgrade generation, selection, and application.
## Upgrades are Resources defined in resources/upgrades/.

const UPGRADE_POOL_PATH := "res://resources/upgrades/"
const CHOICES_PER_OFFER := 3

var _all_upgrades: Array[Resource] = []


func _ready() -> void:
	_load_upgrade_pool()
	EventBus.upgrade_selected.connect(_apply_upgrade)


func _load_upgrade_pool() -> void:
	_all_upgrades.clear()
	var dir := DirAccess.open(UPGRADE_POOL_PATH)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res: Resource = load(UPGRADE_POOL_PATH + file_name)
			if res:
				_all_upgrades.append(res)
		file_name = dir.get_next()


func generate_upgrade_choices() -> Array[Resource]:
	var available := _all_upgrades.filter(func(u): return not u in RunData.collected_upgrades or u.get("stackable"))
	available.shuffle()
	var choices: Array[Resource] = []
	for i in min(CHOICES_PER_OFFER, available.size()):
		choices.append(available[i])
	return choices


func _apply_upgrade(upgrade: Resource) -> void:
	RunData.collected_upgrades.append(upgrade)
	var type: String = upgrade.get("upgrade_type") if upgrade.get("upgrade_type") else ""
	match type:
		"max_health":
			RunData.bonus_max_health += upgrade.get("value")
		"damage":
			RunData.bonus_damage += upgrade.get("value")
		"move_speed":
			RunData.bonus_move_speed += upgrade.get("value")
		"flame_max_energy":
			RunData.bonus_flame_max_energy += upgrade.get("value")
		"flame_decay_reduction":
			RunData.bonus_flame_decay_reduction += upgrade.get("value")
		"vision_radius":
			RunData.bonus_vision_radius += upgrade.get("value")
		"passive":
			if RunData.active_passives.size() < 2:
				RunData.active_passives.append(upgrade)
