extends Control

class_name Settings

@export var back_to_pause_button: Control
@export var exit_to_menu_button: Control
@export var volume_slider:Slider
@export var ui_scale_slider:Slider
@export var ui_scale_label:Label
@export var render_scale_slider:Slider
@export var render_scale_label:Label
@export var msaa_check_box:CheckBox
@export var fxaa_check_box:CheckBox

const config_filepath = "user://settings.cfg"

func _ready() -> void:
	load_settings()

func _on_draw() -> void:
	update()

func _on_visibility_changed() -> void:
	update()

func update() -> void:
	if get_tree().is_paused():
		back_to_pause_button.show()
		exit_to_menu_button.hide()
	else:
		back_to_pause_button.hide()
		exit_to_menu_button.show()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "volume", AudioServer.get_bus_volume_db(0))
	config.set_value("settings", "ui_scale", ProjectSettings.get_setting("display/window/stretch/scale"))
	config.set_value("settings", "render_scale", ProjectSettings.get_setting("rendering/scaling_3d/scale"))
	#config.set_value("settings", "fxaa", ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa"))
	#config.set_value("settings", "msaa", ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d"))
	config.set_value("settings", "fxaa", fxaa_check_box.button_pressed)
	config.set_value("settings", "msaa", msaa_check_box.button_pressed)
	config.save(config_filepath)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(config_filepath)
	if err != OK:
		return
	if config.has_section("settings"):
		_on_volume_slider_value_changed(config.get_value("settings", "volume", 0))
		_on_ui_scale_slider_value_changed(config.get_value("settings", "ui_scale", 1.0))
		_on_ui_scale_slider_drag_ended(true)
		_on_render_scale_slider_value_changed(config.get_value("settings", "render_scale", 1.0))
		_on_fxaa_check_box_toggled(config.get_value("settings", "fxaa", true))
		_on_msaa_check_box_toggled(config.get_value("settings", "msaa", false))

func get_viewport_rid()-> RID:
	return SettingsHandler.get_viewport().get_viewport_rid();

func _on_reset_button_pressed() -> void:
	_on_volume_slider_value_changed(0)
	_on_ui_scale_slider_value_changed(1.0)
	_on_ui_scale_slider_drag_ended(true)
	_on_render_scale_slider_value_changed(1.0)
	_on_fxaa_check_box_toggled(true)
	_on_msaa_check_box_toggled(false)
	save_settings()

func _on_volume_slider_value_changed(value):
	if volume_slider.value != value:
		volume_slider.set_value_no_signal(value)
	if value <= volume_slider.min_value:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, value)
	save_settings()

func _on_ui_scale_slider_value_changed(value: float) -> void:
	if ui_scale_slider.value != value:
		ui_scale_slider.set_value_no_signal(value)
	ui_scale_label.text = "x" + str(value)

func _on_ui_scale_slider_drag_ended(value_changed: bool) -> void:
	if !value_changed:
		return
	ProjectSettings.set_setting("display/window/stretch/scale", ui_scale_slider.value)
	get_window().content_scale_factor = ui_scale_slider.value
	save_settings()

func _on_render_scale_slider_value_changed(value: float) -> void:
	if render_scale_slider.value != value:
		render_scale_slider.set_value_no_signal(value)
	render_scale_label.text = "x" + str(value)
	ProjectSettings.set_setting("rendering/scaling_3d/scale", value)
	RenderingServer.viewport_set_scaling_3d_scale(get_viewport_rid(), value)
	save_settings()

func _on_fxaa_check_box_toggled(toggled_on: bool) -> void:
	if fxaa_check_box.button_pressed != toggled_on:
		fxaa_check_box.set_pressed_no_signal(toggled_on)
	#ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", toggled_on)
	if toggled_on:
		RenderingServer.viewport_set_screen_space_aa(get_viewport_rid(), RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
	else:
		RenderingServer.viewport_set_screen_space_aa(get_viewport_rid(), RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
	save_settings()

func _on_msaa_check_box_toggled(toggled_on: bool) -> void:
	if msaa_check_box.button_pressed != toggled_on:
		msaa_check_box.set_pressed_no_signal(toggled_on)
	#ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", toggled_on)
	if toggled_on:
		RenderingServer.viewport_set_msaa_3d(get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_4X)
	else:
		RenderingServer.viewport_set_msaa_3d(get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
	save_settings()
