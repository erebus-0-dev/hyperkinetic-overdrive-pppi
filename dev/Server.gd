extends Control

## Меню паузы.
class_name PauseMenu

@export var main_menu: Control ## главное меню
@export var settings:Control ## меню настроек

## снять игру с паузы
func unpause() -> void:
	get_tree().set_pause(false)
	if settings.visible:
		settings.hide();
	hide()

## поставить игру на паузу
func pause() -> void:
	get_tree().set_pause(true)
	show()

## обработка кнопки escape
func _process(_delta: float) -> void:
	if PlayerHandler.in_game:
		if Input.is_action_just_pressed(&"escape"):
			if get_tree().is_paused():
				unpause()
			else:
				pause()

## нажатие кнопки - вернуться в игру
func _on_back_to_game_button_pressed() -> void:
	unpause()

## нажатие кнопки - вернуться в главное меню
func _on_exit_to_menu_button_pressed() -> void:
	hide()
	main_menu.load_to_menu()
