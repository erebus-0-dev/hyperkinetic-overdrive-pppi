extends Control

## Главное меню игры.
class_name MainMenu

@export var main_menu_labels: Control ## загрузка фонового уровня
@export var version_label: Control ## надпись номера версии
@export var settings: Control ## меню настроек
@export var controls: Control ## меню управления
@export var credits: Control ## меню авторов
@export var level_selection: Control ## меню выбора уровня

@export var background_level: PackedScene ## фоновый уровень

## по готовности
func _ready() -> void:
	InterfaceHandler.main_menu = self
	version_label.text = "Version: " + ProjectSettings.get_setting(&"application/config/version")
	load_background_level()

## загрузка фонового уровня
func load_background_level() -> void:
	LevelHandler.load_level(background_level, null)

## возвращение в главное меню
func load_to_menu() -> void:
	show()
	get_tree().paused = false
	LevelHandler.clear()
	PlayerHandler.despawn_player()
	load_background_level()

## при переключении видимости
func _on_visibility_changed() -> void:
	main_menu_labels.visible = visible

## нажатие кнопки - играть
func _on_play_button_pressed() -> void:
	hide()
	level_selection.show()

## нажатие кнопки - настройки
func _on_settings_button_pressed() -> void:
	hide()
	settings.show()

## нажатие кнопки - управление
func _on_controls_button_pressed() -> void:
	hide()
	controls.show()

## нажатие кнопки - авторы
func _on_credits_button_pressed() -> void:
	hide()
	credits.show()

## нажатие кнопки - выход
func _on_exit_button_pressed() -> void:
	get_tree().quit()
