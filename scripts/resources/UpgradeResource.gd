extends Resource
## Data resource defining a single upgrade or passive ability.

@export var upgrade_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var upgrade_type: String = ""  # max_health | damage | move_speed | flame_max_energy | flame_decay_reduction | vision_radius | passive
@export var value: float = 0.0
@export var stackable: bool = false
@export var rarity: int = 0  # 0=common, 1=uncommon, 2=rare
