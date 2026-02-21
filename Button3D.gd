extends Mechanism3D

class_name Button3D

@export var toggle_mode:bool = true # режим кнопки, true - переключатель, false - нажимаемая кнопка
@export var pressed_time:float = 1.0 # время, в течение которого кнопка будет нажата (если toggle_mode = false)

@onready var button_animator:AnimationPlayer = $AnimationPlayer
@onready var press_timer:Timer = $PressTimer

func on_activation() -> void:
	button_animator.queue(&"activated")

func on_deactivation() -> void:
	button_animator.queue(&"deactivated")

func click():
	if button_animator == null:
		return
	button_animator.clear_queue()
	button_animator.stop(true)
	if toggle_mode:
		switch()
	else:
		activate()
		press_timer.stop()
		press_timer.wait_time = pressed_time
		press_timer.start()
	button_animator.queue(&"pressed")

func _on_press_timer_timeout() -> void:
	deactivate()
