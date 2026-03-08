extends Node

## Автоматизированный вызов метода ноды.
class_name ObjectCall

@export var object_to_call:Node ## нода, метод которой будет вызван
@export var method_to_call:StringName ## имя вызываемого метода
@export var arguments:Array ## аргументы вызова метода

func execute() -> void:
	if object_to_call != null and object_to_call.has_method(method_to_call):
		if arguments.is_empty():
			object_to_call.call(method_to_call)
		else:
			object_to_call.call(method_to_call, arguments)
