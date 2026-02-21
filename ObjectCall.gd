extends Node

class_name ObjectCall # базовый класс для отправляемых от механизмов вызовов

@export var object_to_call:Node
@export var method_to_call:StringName
@export var arguments:Array

func execute() -> void:
	if object_to_call != null and object_to_call.has_method(method_to_call):
		if arguments.is_empty():
			object_to_call.call(method_to_call)
		else:
			object_to_call.call(method_to_call, arguments)
