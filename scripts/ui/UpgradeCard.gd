extends PanelContainer

signal selected

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var select_button: Button = %SelectButton


func setup(upgrade: Resource) -> void:
	name_label.text = upgrade.get("upgrade_name") if upgrade.get("upgrade_name") else "Unknown"
	description_label.text = upgrade.get("description") if upgrade.get("description") else ""
	if upgrade.get("icon"):
		icon.texture = upgrade.get("icon")
	select_button.pressed.connect(func(): selected.emit())
