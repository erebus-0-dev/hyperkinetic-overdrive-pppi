extends Control

class_name MainMenu

@export var main_menu_labels: Control
@export var version_label: Control
@export var settings: Control
@export var controls: Control
@export var credits: Control
@export var level_selection: Control
@export var background_level: PackedScene

func _ready() -> void:
	InterfaceHandler.main_menu = self
	version_label.text = "Version: " + ProjectSettings.get_setting(&"application/config/version")
	load_background_level()

func _on_visibility_changed() -> void:
	main_menu_labels.visible = visible

func load_to_menu() -> void:
	show()
	get_tree().paused = false
	LevelHandler.clear()
	PlayerHandler.despawn_player()
	load_background_level()

func load_background_level() -> void:
	LevelHandler.load_level(background_level, null)

func _on_play_button_pressed() -> void:
	hide()
	level_selection.show()

func _on_settings_button_pressed() -> void:
	hide()
	settings.show()

func _on_controls_button_pressed() -> void:
	hide()
	controls.show()

func _on_credits_button_pressed() -> void:
	hide()
	credits.show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
