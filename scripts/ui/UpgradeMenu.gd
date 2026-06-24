extends CanvasLayer
## Displayed between rooms — shows 3 upgrade choices for the player to pick.

@onready var card_container: HBoxContainer = %CardContainer
@onready var title_label: Label = %TitleLabel

const UPGRADE_CARD_SCENE := preload("res://scenes/ui/upgrade_card.tscn")


func _ready() -> void:
	EventBus.upgrade_offered.connect(_show_upgrades)
	hide()


func _show_upgrades(upgrades: Array) -> void:
	show()
	for child in card_container.get_children():
		child.queue_free()
	for upgrade in upgrades:
		var card := UPGRADE_CARD_SCENE.instantiate()
		card_container.add_child(card)
		card.setup(upgrade)
		card.selected.connect(_on_upgrade_chosen.bind(upgrade))


func _on_upgrade_chosen(upgrade: Resource) -> void:
	hide()
	EventBus.upgrade_selected.emit(upgrade)
