extends ScrollContainer

## Список уровней. Содержит карточки уровней (LevelCard).
class_name LevelSelectionList

@export var level_selection_menu:Control ## меню выбора уровня, которое должно быть скрыто при выборе уровня

## по готовности
func _ready() -> void:
	for child in $MarginContainer/VBoxContainer.get_children():
		if child is LevelCard:
			child.play_button_pressed.connect(hide_ui)

## скрытие меню выбора уровня
func hide_ui():
	level_selection_menu.hide()
