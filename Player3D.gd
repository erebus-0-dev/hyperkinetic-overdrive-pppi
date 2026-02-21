extends RigidBody3D

class_name Player3D

var movement_input: Vector2 = Vector2.ZERO # ввод движения
@export var acceleration_value: float = 50.0 # модификатор скорости движения
var acceleration: Vector3 = Vector3.ZERO # ускорение
@export var deacceleration_value: float = 50.0 # модификатор торможения

@export var sprint_modifier: float = 2.0 # модификатор ускорения при беге

@export var max_available_jumps: int = 1 # максимальное кол-во прыжков после касания земли
var available_jumps: int = max_available_jumps # текущее доступное кол-во прыжков

@export var max_dash_energy: float = 3 # максимальное кол-во дэшей
var dash_energy: float = max_dash_energy # текущее доступное кол-во дэшей

@export var dash_impulse: float = 2500.0 # импульс дэша
@export var jump_impulse: float = 1500.0 # импульс прыжка
@export var throw_impulse: float = 1000.0 # импульс броска
@export var fast_falling_force: float = 10000.0 # сила быстрого падения

@export var anti_drift_mod: float = 2.0 # модификатор системы анти-дрифта - сохранение инерции при повороте
@export var air_control: bool = false # управление в полёте, основано на системе анти-дрифт

@export var aim_animation_speed_mod: float = 50.0 # модификатор скорости прицеливания

var picked_object:Pickable3D # поднятый предмет
var interaction_collider:Node3D # с чем сталкивается interaction_raycast
var fall_velocity:float = 0.0 # скорость падения игрока
var aim_pressed_on:bool = false # зажато ли прицеливание
var crouch_pressed_on:bool = false # зажато ли карабканье
var is_on_ground:bool = false # стоит ли игрок на земле
var were_on_ground:bool = false # стоял ли игрок на земле в предыдущем кадре

@onready var interaction_raycast:RayCast3D = $CameraJoint/InteractionRaycast # Raycast3D для нажатия кнопок и прочих взаимодействий с миром

@onready var camera_joint = $CameraJoint # точка, вокруг которой вращается камера
@onready var camera = $CameraJoint/CameraSpringArm3D/Camera3D # камера
@onready var camera_spring_arm = $CameraJoint/CameraSpringArm3D # крепление камеры
@onready var camera_position_marker = $CameraPositionMarker # маркер положения камеры, который камера постоянно преследует
@onready var camera_animator= $CameraAnimationPlayer # аниматор камеры

@onready var mesh = $MeshInstance3D # главный меш игрока

@onready var ground_raycast = $GroundRaycast # рейкаст до земли

@onready var hand_marker = $CameraJoint/HandMarker # маркер позиции мяча при удержании

@onready var crosshair = $Interface/Control/Crosshair # прицел
@onready var dash_charge_bar = $Interface/Control/DashChargeBar # бар дэша
@onready var throw_charge_bar = $Interface/Control/ThrowChargeBar # бар зарядки броска
@onready var throw_charge_bar_anim = $Interface/Control/ThrowChargeBar/AnimationPlayer # аниматор бара зарядки броска

@onready var flashlight = $CameraJoint/Flashlight # фонарик

# бежит ли игрок
func get_sprint_modifier() -> float:
	if Input.is_action_pressed(&"sprint"):
		return sprint_modifier
	else:
		return 1.0

# установка прозрачности мяча
func set_picked_object_transparency(value: float) -> void:
	if picked_object != null and picked_object.has_node(^"MeshInstance3D"):
		picked_object.get_node(^"MeshInstance3D").transparency = value

# универсальное обновление бара
func update_bar(value:float, max_value:float, bar:Range) -> void:
	if bar.max_value != max_value:
		bar.max_value = max_value
	if bar.value != value:
		bar.value = value

# по готовности
func _ready() -> void:
	# автонастройка мыши
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# исключения коллизии
	interaction_raycast.add_exception(self)
	#ground_raycast.add_exception(self)

# при деспавне игрока
func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

# обработка движения мыши
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		apply_torque_impulse(Vector3.DOWN * event.relative.x * SettingsHandler.mouse_sensetivity_horizontal)
		#apply_torque(Vector3.DOWN * event.relative.x * SettingsHandler.mouse_sensetivity_horizontal)
		#rotation += Vector3.DOWN * event.relative.x * SettingsHandler.mouse_sensetivity_horizontal / 180
		camera_joint.rotation.x = clamp(camera_joint.rotation.x - event.relative.y * 0.002 * SettingsHandler.mouse_sensetivity_vertical, -PI/2, PI/2)

# каждый кадр отрисовки
func _process(delta: float) -> void:
	
	# компенсация изменения таймскейла
	delta /= Engine.time_scale
	
	# во время паузы
	if get_tree().paused:
		# настройка режима мыши
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	# вне паузы
	else:
		# настройка режима мыши
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# фонарик
		if Input.is_action_just_pressed(&"flashlight"):
			flashlight.visible = !flashlight.visible
		
		# движение
		movement_input = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back").normalized() * get_sprint_modifier()
		
		# прицеливание
		aim_pressed_on = Input.is_action_pressed(&"aim")
		
		# прыжок
		if available_jumps >= 1 and Input.is_action_just_pressed(&"jump"):
			apply_central_impulse(Vector3(0.0, jump_impulse, 0.0))
			available_jumps -= 1
		
		# быстрое приземление
		crouch_pressed_on = Input.is_action_pressed(&"crouch")
		
		# дэш
		if dash_energy >= max_dash_energy:
			dash_energy = max_dash_energy
		else:
			dash_energy += delta
		update_bar(dash_energy, max_dash_energy, dash_charge_bar)
		if Input.is_action_just_pressed(&"dash") and dash_energy >= 1:
			dash_energy -= 1
			apply_central_impulse(Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * dash_impulse)
		
		# нажатие кнопки, подбор предмета и прочие взаиомедйствия
		interaction_collider = interaction_raycast.get_collider()
		crosshair.frame = 0
		if interaction_collider != null:
			# подбор предмета
			if picked_object == null and interaction_collider is Pickable3D and Input.is_action_pressed(&"interaction_main"):
				set_picked_object_transparency(0.0)
				picked_object = interaction_collider
				set_picked_object_transparency(0.75)
			# прочее
			else:
				if interaction_collider.has_method(&"click"):
					crosshair.frame = 1
					if Input.is_action_just_pressed(&"interaction_main"):
						interaction_raycast.get_collider().click()
				elif interaction_collider.has_method(&"press"):
					crosshair.frame = 1
					if Input.is_action_pressed(&"interaction_main"):
						interaction_raycast.get_collider().press()
				elif interaction_collider is Pickable3D:
					crosshair.frame = 2
		
		# бросок
		if Input.is_action_just_released(&"interaction_main") and picked_object != null:
			if throw_charge_bar_anim.is_playing():
				picked_object.linear_velocity = Vector3.ZERO
				picked_object.angular_velocity = Vector3.ZERO
				picked_object.apply_central_impulse((picked_object.global_position - camera.global_position).normalized() * throw_impulse * throw_charge_bar.value)
			set_picked_object_transparency(0.0)
			picked_object = null
		
		# удержание мяча
		if picked_object != null and Input.is_action_pressed(&"interaction_main"):
			picked_object.linear_velocity = linear_velocity
			picked_object.angular_velocity = angular_velocity
			picked_object.global_position = hand_marker.global_position
			picked_object.global_rotation = hand_marker.global_rotation
			# зарядка броска
			if Input.is_action_pressed(&"interaction_alt"):
				throw_charge_bar_anim.play(&"main")
				throw_charge_bar.visible = true
			else:
				throw_charge_bar_anim.stop()
				throw_charge_bar.visible = false
		else:
			throw_charge_bar_anim.play(&"RESET")
			throw_charge_bar_anim.stop()
			throw_charge_bar.visible = false
		
		# прицеливание
		if aim_pressed_on:
			camera.fov = clamp(lerpf(camera.fov, SettingsHandler.camera_fov_aim, min(delta * aim_animation_speed_mod, 0.5)), 1.0, 179.0)
		else:
			camera.fov = clamp(lerpf(camera.fov, SettingsHandler.camera_fov, min(delta * aim_animation_speed_mod, 0.5)), 1.0, 179.0)
		
		# зум камеры
		if Input.is_action_just_released(&"zoom_out"):
			camera_spring_arm.spring_length += SettingsHandler.zoom_speed
		elif Input.is_action_just_released(&"zoom_in"):
			camera_spring_arm.spring_length -= SettingsHandler.zoom_speed
		if camera_spring_arm.spring_length < 0.0:
			camera_spring_arm.spring_length = 0.0
		mesh.visible = camera_spring_arm.spring_length != 0.0
		
		# пошатывание камеры
		if is_on_ground:
			camera_animator.speed_scale = min(sqrt(linear_velocity.length() * 0.1), 10.0)
		else:
			camera_animator.speed_scale = 1.0
		if movement_input == Vector2.ZERO:
			camera_animator.play(&"RESET")
			camera_joint.position = lerp(camera_joint.position, camera_position_marker.position, SettingsHandler.camera_shake_weight * delta)
		else:
			if !camera_animator.is_playing():
				if movement_input.y > 0:
					camera_animator.play(&"sprint")
				elif movement_input.y < 0:
					camera_animator.play(&"sprint_mirrored")
				else:
					if Engine.get_frames_drawn() % 2 == 0:
						camera_animator.play(&"sprint")
					else:
						camera_animator.play(&"sprint_mirrored")
			camera_joint.position = lerp(camera_joint.position, camera_position_marker.position, min(SettingsHandler.camera_shake_weight * delta, 1.0))

# каждый кадр физики
func _physics_process(delta: float) -> void:
	
	# обновлениен статуса нахождения на земле
	were_on_ground = is_on_ground
	is_on_ground = ground_raycast.is_colliding()
	
	# сброс лимита прыжков
	#if available_jumps < max_available_jumps && is_on_ground:
	if available_jumps < max_available_jumps && is_on_ground && !were_on_ground:
		available_jumps = max_available_jumps
	
	# быстрое приземление
	if crouch_pressed_on:
		if !is_on_ground:
			apply_central_force(Vector3.DOWN * fast_falling_force)
	
	# движение
	if movement_input != Vector2.ZERO:
		acceleration = Vector3(movement_input.x, 0.0, movement_input.y).rotated(Vector3.UP, rotation.y) * acceleration_value
		linear_velocity += acceleration * delta / sqrt(sqrt(sqrt(1.0 + linear_velocity.length_squared())))
	else:
		if is_on_ground:
			#acceleration = linear_velocity.normalized() * deacceleration_value * -1
			acceleration = linear_velocity.normalized() * linear_velocity.length() * -1
			linear_velocity += acceleration * delta
		else:
			acceleration = Vector3.ZERO
	
	# анти-дрифт
	fall_velocity = linear_velocity.y
	if is_on_ground or air_control:
		linear_velocity = lerp(linear_velocity, linear_velocity.length() * acceleration.normalized(), min(anti_drift_mod * delta, 1.0))
		linear_velocity.y = fall_velocity
