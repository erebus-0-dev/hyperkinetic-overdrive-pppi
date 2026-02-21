extends Mechanism3D

class_name CallingMechanism3D # базовый класс для механизмов с встроенным вызовом других объектов

@export var object_calls_on_activation:Array[ObjectCall] # вызовы, выполняемые только при активации
@export var object_calls_on_deactivation:Array[ObjectCall] # вызовы, выполняемые только при деактивации
@export var object_calls_on_state_change:Array[ObjectCall] # вызовы, выполняемые при изменении состояния

func _ready() -> void:
	self.activated.connect(when_activated)
	self.deactivated.connect(when_deactivated)
	self.state_changed.connect(when_state_changed)

func when_activated() -> void:
	call_objects(object_calls_on_activation)

func when_deactivated() -> void:
	call_objects(object_calls_on_deactivation)

func when_state_changed() -> void:
	call_objects(object_calls_on_state_change)
