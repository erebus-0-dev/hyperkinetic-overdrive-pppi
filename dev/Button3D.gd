extends Mechanism3D

## МЕХАНИЗМ - Кнопка.
class_name Button3D

@export var toggle_mode:bool = true ## режим кнопки, true - переключатель, false - нажимаемая кнопка
@export var pressed_time:float = 1.0 ## время, в течение которого кнопка будет нажата (если toggle_mode = false)

@onready var button_animator:AnimationPlayer = $ButtonAnimator ## аниматор кнопки
@onready var press_timer:Timer = $PressTimer ## таймер нахождения в нажатом состоянии

## при включении
func is_enabled() -> void:
	button_animator.queue(&"activated")

## при выключении
func is_disabled() -> void:
	button_animator.queue(&"deactivated")

## клик по кнопке
func click():
	if button_animator == null:
		return
	button_animator.clear_queue()
	button_animator.stop(true)
	if toggle_mode:
		switch()
	else:
		enable()
		press_timer.stop()
		press_timer.wait_time = pressed_time
		press_timer.start()
	button_animator.queue(&"pressed")

## отжатие кнопки по таймеру
func _on_press_timer_timeout() -> void:
	disable()
