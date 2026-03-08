extends Mechanism3D

## МЕХАНИЗМ - то же, что и Mechanism3D? но со встроенным вызовом других объектов
class_name CallingMechanism3D

@export var object_calls_on_activation:Array[ObjectCall] ## вызовы, выполняемые только при активации механизма
@export var object_calls_on_deactivation:Array[ObjectCall] ## вызовы, выполняемые только при деактивации механизма
@export var object_calls_on_state_change:Array[ObjectCall] ## вызовы, выполняемые при изменении состояния механизма

func _ready() -> void:
	self.enabled.connect(when_activated)
	self.disabled.connect(when_deactivated)
	self.state_changed.connect(when_state_changed)

## вызовы, выполняемые только при активации механизма
func when_activated() -> void:
	call_objects(object_calls_on_activation)

## вызовы, выполняемые только при деактивации механизма
func when_deactivated() -> void:
	call_objects(object_calls_on_deactivation)

## вызовы, выполняемые при изменении состояния механизма
func when_state_changed() -> void:
	call_objects(object_calls_on_state_change)

## выполнение вызовов
func call_objects(calls: Array[ObjectCall]) -> void:
	for obj in calls:
		obj.execute()
