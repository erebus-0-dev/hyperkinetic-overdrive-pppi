extends Node

# синглтон для механики остановки времени
var time_scale_modifier:float = 10.0
var player_ignore_time_scale:bool = true
var active:bool = false

func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed(&"time_stop"):
		#get_tree().paused = !get_tree().paused
	if Input.is_action_pressed(&"time_stop"):
		Engine.time_scale = 1.0/time_scale_modifier
		active = true
	else:
		Engine.time_scale = 1.0
		active = false
