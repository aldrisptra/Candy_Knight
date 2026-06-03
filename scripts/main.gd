extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var button_click_sound: AudioStreamPlayer2D = $ButtonClickSound

# -----------------------------
# MAIN MENU
# -----------------------------
var main_menu: CanvasLayer
var main_menu_control: Control
var menu_buttons: Control
var start_button: TextureButton
var settings_button: TextureButton
var tutorial_button: TextureButton
var credits_button: TextureButton
var home_button: TextureButton

var settings_panel: CanvasItem
var tutorial_panel: CanvasItem
var credits_panel: CanvasItem
var menu_background: CanvasItem
var fade_black: ColorRect

var music_toggle_button: Button
var sfx_toggle_button: Button

var music_enabled: bool = true
var sfx_enabled: bool = true

var start_button_tween: Tween
var start_button_base_position: Vector2
var has_start_button_base_position: bool = false

var is_starting_game: bool = false
var menu_background_base_scale: Vector2 = Vector2.ONE
var menu_background_base_position: Vector2 = Vector2.ZERO
var has_menu_background_base_transform: bool = false

# -----------------------------
# WIN SCREEN LAMA
# -----------------------------
var win_screen: CanvasLayer
var win_control: Control
var win_label: Label
var start_again_button: Button
var win_color_rect: ColorRect

# -----------------------------
# RESULT SCREEN
# -----------------------------
var result_screen: CanvasLayer
var result_control: Control
var result_color_rect: ColorRect
var you_win_image: TextureRect
var you_lose_image: TextureRect
var result_restart_button: TextureButton
var result_home_button: TextureButton

# Ending dialog
var player_win_image: TextureRect
var princess_win_image: TextureRect
var player_dialog_label
var princess_dialog_label
var next_button: BaseButton
var ending_dialog_step: int = 0

# -----------------------------
# LEVEL DATA
# -----------------------------
var level: int = 1
var max_level: int = 3
var current_level_root: Node = null


func _ready() -> void:
	_setup_main_menu()
	_setup_win_screen()
	_setup_result_screen()

	hud.visible = false

	current_level_root = get_node_or_null("LevelRoot")
	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null

	_show_main_menu()


# -----------------------------
# MAIN MENU SETUP
# -----------------------------
func _setup_main_menu() -> void:
	main_menu = get_node_or_null("MainMenu")

	if main_menu == null:
		print("Node MainMenu tidak ditemukan!")
		return

	main_menu_control = main_menu.get_node_or_null("Control")

	if main_menu_control == null:
		print("Node Control tidak ditemukan di MainMenu!")
		return

	menu_buttons = main_menu_control.get_node_or_null("MenuButtons")

	menu_background = main_menu_control.get_node_or_null("Background")
	fade_black = main_menu_control.get_node_or_null("FadeBlack")

	start_button = main_menu_control.find_child("StartButton", true, false)
	settings_button = main_menu_control.find_child("SettingsButton", true, false)
	tutorial_button = main_menu_control.find_child("TutorialButton", true, false)
	credits_button = main_menu_control.find_child("CreditsButton", true, false)
	home_button = main_menu_control.find_child("HomeButton", true, false)

	settings_panel = main_menu_control.get_node_or_null("SettingsPanel")
	tutorial_panel = main_menu_control.get_node_or_null("TutorialPanel")
	credits_panel = main_menu_control.get_node_or_null("CreditsPanel")

	music_toggle_button = main_menu_control.find_child("MusicToggleButton", true, false)
	sfx_toggle_button = main_menu_control.find_child("SfxToggleButton", true, false)

	main_menu.visible = true
	main_menu_control.visible = true
	main_menu_control.set_anchors_preset(Control.PRESET_FULL_RECT)

	if menu_buttons:
		menu_buttons.visible = true
		menu_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if menu_background and menu_background is Control:
		menu_background.visible = true
		menu_background.set_anchors_preset(Control.PRESET_FULL_RECT)
		menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if fade_black:
		fade_black.visible = true
		fade_black.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_black.color = Color.BLACK
		fade_black.modulate.a = 0.0
		fade_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fade_black.z_index = 100
		fade_black.z_as_relative = false
		fade_black.move_to_front()
	else:
		print("FadeBlack tidak ditemukan di MainMenu!")

	if settings_panel and settings_panel is Control:
		settings_panel.visible = false
		settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if tutorial_panel and tutorial_panel is Control:
		tutorial_panel.visible = false
		tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if credits_panel and credits_panel is Control:
		credits_panel.visible = false
		credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if start_button:
		start_button.visible = true
		start_button.disabled = false
		start_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not start_button.pressed.is_connected(_on_start_button_pressed):
			start_button.pressed.connect(_on_start_button_pressed)

		_start_button_float()
	else:
		print("StartButton tidak ditemukan!")

	if settings_button:
		settings_button.visible = true
		settings_button.disabled = false
		settings_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not settings_button.pressed.is_connected(_on_settings_button_pressed):
			settings_button.pressed.connect(_on_settings_button_pressed)
	else:
		print("SettingsButton tidak ditemukan!")

	if tutorial_button:
		tutorial_button.visible = true
		tutorial_button.disabled = false
		tutorial_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not tutorial_button.pressed.is_connected(_on_tutorial_button_pressed):
			tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	else:
		print("TutorialButton tidak ditemukan!")

	if credits_button:
		credits_button.visible = true
		credits_button.disabled = false
		credits_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not credits_button.pressed.is_connected(_on_credits_button_pressed):
			credits_button.pressed.connect(_on_credits_button_pressed)
	else:
		print("CreditsButton tidak ditemukan!")

	if home_button:
		home_button.visible = false
		home_button.disabled = false
		home_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not home_button.pressed.is_connected(_on_home_button_pressed):
			home_button.pressed.connect(_on_home_button_pressed)
	else:
		print("HomeButton tidak ditemukan!")

	if music_toggle_button:
		music_toggle_button.text = "ON"
		music_toggle_button.disabled = false
		music_toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not music_toggle_button.pressed.is_connected(_on_music_toggle_pressed):
			music_toggle_button.pressed.connect(_on_music_toggle_pressed)
	else:
		print("MusicToggleButton tidak ditemukan!")

	if sfx_toggle_button:
		sfx_toggle_button.text = "ON"
		sfx_toggle_button.disabled = false
		sfx_toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not sfx_toggle_button.pressed.is_connected(_on_sfx_toggle_pressed):
			sfx_toggle_button.pressed.connect(_on_sfx_toggle_pressed)
	else:
		print("SfxToggleButton tidak ditemukan!")


func _show_main_menu() -> void:
	_reset_menu_visuals()

	if main_menu:
		main_menu.visible = true

	if menu_buttons:
		menu_buttons.visible = true

	if result_screen:
		result_screen.visible = false

	hud.visible = false

	if win_screen:
		win_screen.visible = false

	if start_button:
		start_button.visible = true
		start_button.disabled = false
		_start_button_float()

	if settings_button:
		settings_button.visible = true
		settings_button.disabled = false

	if tutorial_button:
		tutorial_button.visible = true
		tutorial_button.disabled = false

	if credits_button:
		credits_button.visible = true
		credits_button.disabled = false

	if home_button:
		home_button.visible = false

	if settings_panel:
		settings_panel.visible = false
		if settings_panel is Control:
			settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if tutorial_panel:
		tutorial_panel.visible = false
		if tutorial_panel is Control:
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if credits_panel:
		credits_panel.visible = false
		if credits_panel is Control:
			credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


# -----------------------------
# BUTTON CLICK SOUND
# -----------------------------
func _play_button_click() -> void:
	if not sfx_enabled:
		return

	if button_click_sound:
		button_click_sound.stop()
		button_click_sound.play()


# -----------------------------
# START BUTTON ANIMATION
# -----------------------------
func _start_button_float() -> void:
	if start_button == null:
		return

	await get_tree().process_frame

	if start_button == null:
		return

	start_button.visible = true
	start_button.disabled = false

	if not has_start_button_base_position:
		start_button_base_position = start_button.position
		has_start_button_base_position = true

	if start_button_tween:
		start_button_tween.kill()
		start_button_tween = null

	start_button.position = start_button_base_position

	var up_position: Vector2 = start_button_base_position + Vector2(0, -10)

	start_button_tween = create_tween()
	start_button_tween.set_loops()
	start_button_tween.tween_property(start_button, "position", up_position, 0.6)
	start_button_tween.tween_property(start_button, "position", start_button_base_position, 0.6)


func _stop_start_button_animation() -> void:
	if start_button_tween:
		start_button_tween.kill()
		start_button_tween = null

	if start_button:
		start_button.position = start_button_base_position


func _reset_menu_visuals() -> void:
	is_starting_game = false

	if menu_background and menu_background is Control:
		var bg := menu_background as Control

		if has_menu_background_base_transform:
			bg.scale = menu_background_base_scale
			bg.position = menu_background_base_position

		bg.modulate.a = 1.0

	if fade_black:
		fade_black.visible = true
		fade_black.color = Color.BLACK
		fade_black.modulate.a = 0.0
		fade_black.z_index = 100
		fade_black.z_as_relative = false
		fade_black.move_to_front()

	if start_button:
		start_button.visible = true
		start_button.modulate.a = 1.0
		start_button.disabled = false

	if settings_button:
		settings_button.visible = true
		settings_button.modulate.a = 1.0
		settings_button.disabled = false

	if tutorial_button:
		tutorial_button.visible = true
		tutorial_button.modulate.a = 1.0
		tutorial_button.disabled = false

	if credits_button:
		credits_button.visible = true
		credits_button.modulate.a = 1.0
		credits_button.disabled = false

	if home_button:
		home_button.visible = false
		home_button.modulate.a = 1.0
		home_button.disabled = false


func _play_start_intro_transition() -> void:
	if is_starting_game:
		return

	is_starting_game = true
	_stop_start_button_animation()

	if start_button:
		start_button.disabled = true
	if settings_button:
		settings_button.disabled = true
	if tutorial_button:
		tutorial_button.disabled = true
	if credits_button:
		credits_button.disabled = true
	if home_button:
		home_button.disabled = true

	await get_tree().process_frame

	if menu_background and menu_background is Control:
		var bg := menu_background as Control

		if not has_menu_background_base_transform:
			menu_background_base_scale = bg.scale
			menu_background_base_position = bg.position
			has_menu_background_base_transform = true

		bg.pivot_offset = bg.size / 2

	if fade_black:
		fade_black.visible = true
		fade_black.color = Color.BLACK
		fade_black.modulate.a = 0.0
		fade_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fade_black.z_index = 100
		fade_black.z_as_relative = false
		fade_black.move_to_front()

	var tween := create_tween()
	tween.set_parallel(true)

	if start_button:
		tween.tween_property(start_button, "modulate:a", 0.0, 0.35)
	if settings_button:
		tween.tween_property(settings_button, "modulate:a", 0.0, 0.35)
	if tutorial_button:
		tween.tween_property(tutorial_button, "modulate:a", 0.0, 0.35)
	if credits_button:
		tween.tween_property(credits_button, "modulate:a", 0.0, 0.35)

	if menu_background and menu_background is Control:
		var bg := menu_background as Control
		tween.tween_property(bg, "scale", menu_background_base_scale * 1.35, 1.2)

	if fade_black:
		tween.tween_property(fade_black, "modulate:a", 1.0, 1.2)

	await get_tree().create_timer(1.25).timeout

	_start_game_after_intro()


func _start_game_after_intro() -> void:
	print("Masuk ke game setelah intro")

	if main_menu:
		main_menu.visible = false

	if result_screen:
		result_screen.visible = false

	hud.visible = true

	level = 1
	PlayerStats.reset()
	_load_level(level)

	is_starting_game = false


# -----------------------------
# WIN SCREEN LAMA SETUP
# -----------------------------
func _setup_win_screen() -> void:
	win_screen = get_node_or_null("WinScreen")

	if win_screen:
		win_control = win_screen.find_child("Control", true, false)
		win_label = win_screen.find_child("Label", true, false)
		start_again_button = win_screen.find_child("Button", true, false)
		win_color_rect = win_screen.find_child("ColorRect", true, false)

		win_screen.visible = false

		if win_control:
			win_control.set_anchors_preset(Control.PRESET_FULL_RECT)

		if win_color_rect:
			win_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			win_color_rect.color = Color(0, 0, 0, 0.7)
			win_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if win_label:
			win_label.text = "CONGRATS!"
			win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			win_label.add_theme_color_override("font_color", Color.WHITE)

		if start_again_button:
			start_again_button.text = "Start Again"

			if not start_again_button.pressed.is_connected(_on_start_again_pressed):
				start_again_button.pressed.connect(_on_start_again_pressed)


# -----------------------------
# RESULT SCREEN SETUP
# -----------------------------
func _setup_result_screen() -> void:
	result_screen = get_node_or_null("ResultScreen")

	if result_screen == null:
		print("ResultScreen tidak ditemukan!")
		return

	result_control = result_screen.find_child("Control", true, false)
	result_color_rect = result_screen.find_child("ColorRect", true, false)
	you_win_image = result_screen.find_child("YouWinImage", true, false)
	you_lose_image = result_screen.find_child("YouLoseImage", true, false)
	result_restart_button = result_screen.find_child("RestartButton", true, false)
	result_home_button = result_screen.find_child("ResultHomeButton", true, false)

	player_win_image = result_screen.find_child("PlayerWinImage", true, false)
	princess_win_image = result_screen.find_child("PrincessWinImage", true, false)
	player_dialog_label = result_screen.find_child("PlayerDialogLabel", true, false)
	princess_dialog_label = result_screen.find_child("PrincessDialogLabel", true, false)
	next_button = result_screen.find_child("NextButton", true, false)

	result_screen.visible = false

	if result_control:
		result_control.set_anchors_preset(Control.PRESET_FULL_RECT)

	if result_color_rect:
		result_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		result_color_rect.color = Color(0, 0, 0, 0.65)
		result_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if you_win_image:
		you_win_image.visible = false
		you_win_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if you_lose_image:
		you_lose_image.visible = false
		you_lose_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if player_win_image:
		player_win_image.visible = false
		player_win_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if princess_win_image:
		princess_win_image.visible = false
		princess_win_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if player_dialog_label:
		player_dialog_label.visible = false
		player_dialog_label.text = "Tuan Putri, akhirnya aku menemukanmu!\nKerajaan Permen sudah aman sekarang."

	if princess_dialog_label:
		princess_dialog_label.visible = false
		princess_dialog_label.text = "Terima kasih, Kesatria!\nBerkat keberanianmu, kerajaan ini kembali damai."

	if next_button:
		next_button.visible = false
		next_button.disabled = false
		next_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not next_button.pressed.is_connected(_on_next_button_pressed):
			next_button.pressed.connect(_on_next_button_pressed)
	else:
		print("NextButton tidak ditemukan di ResultScreen!")

	if result_restart_button:
		result_restart_button.visible = true
		result_restart_button.disabled = false
		result_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not result_restart_button.pressed.is_connected(_on_result_restart_pressed):
			result_restart_button.pressed.connect(_on_result_restart_pressed)
	else:
		print("RestartButton tidak ditemukan di ResultScreen!")

	if result_home_button:
		result_home_button.visible = true
		result_home_button.disabled = false
		result_home_button.mouse_filter = Control.MOUSE_FILTER_STOP

		if not result_home_button.pressed.is_connected(_on_result_home_pressed):
			result_home_button.pressed.connect(_on_result_home_pressed)
	else:
		print("ResultHomeButton tidak ditemukan di ResultScreen!")


func _show_result_screen(is_win: bool) -> void:
	hud.visible = false

	if main_menu:
		main_menu.visible = false

	if win_screen:
		win_screen.visible = false

	if result_screen == null:
		print("ResultScreen belum ada!")
		return

	result_screen.visible = true

	if result_color_rect:
		result_color_rect.visible = true
		result_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		result_color_rect.color = Color(0, 0, 0, 0.65)
		result_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if player_win_image:
		player_win_image.visible = false

	if princess_win_image:
		princess_win_image.visible = false

	if player_dialog_label:
		player_dialog_label.visible = false

	if princess_dialog_label:
		princess_dialog_label.visible = false

	if next_button:
		next_button.visible = false
		next_button.disabled = true

	if you_win_image:
		you_win_image.visible = is_win
		you_win_image.scale = Vector2(0.4, 0.4)
		you_win_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if you_lose_image:
		you_lose_image.visible = not is_win
		you_lose_image.scale = Vector2(0.4, 0.4)
		you_lose_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if result_restart_button:
		result_restart_button.visible = true
		result_restart_button.disabled = false
		result_restart_button.modulate.a = 1.0
		result_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		result_restart_button.z_index = 50
		result_restart_button.z_as_relative = false
		result_restart_button.move_to_front()
		result_restart_button.scale = Vector2(0.8, 0.8)

	if result_home_button:
		result_home_button.visible = true
		result_home_button.disabled = false
		result_home_button.modulate.a = 1.0
		result_home_button.mouse_filter = Control.MOUSE_FILTER_STOP
		result_home_button.z_index = 50
		result_home_button.z_as_relative = false
		result_home_button.move_to_front()
		result_home_button.scale = Vector2(0.8, 0.8)

	var tween := create_tween()

	if is_win and you_win_image:
		tween.tween_property(you_win_image, "scale", Vector2(1.1, 1.1), 0.25)
		tween.tween_property(you_win_image, "scale", Vector2(1.0, 1.0), 0.15)

	if not is_win and you_lose_image:
		tween.tween_property(you_lose_image, "scale", Vector2(1.1, 1.1), 0.25)
		tween.tween_property(you_lose_image, "scale", Vector2(1.0, 1.0), 0.15)

	if result_restart_button:
		tween.tween_property(result_restart_button, "scale", Vector2(1.0, 1.0), 0.2)

	if result_home_button:
		tween.tween_property(result_home_button, "scale", Vector2(1.0, 1.0), 0.2)


func _show_ending_dialog() -> void:
	hud.visible = false

	if main_menu:
		main_menu.visible = false

	if win_screen:
		win_screen.visible = false

	if result_screen == null:
		print("ResultScreen belum ada!")
		return

	result_screen.visible = true
	ending_dialog_step = 0

	if result_color_rect:
		result_color_rect.visible = true
		result_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		result_color_rect.color = Color(0, 0, 0, 0.65)
		result_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if you_win_image:
		you_win_image.visible = false

	if you_lose_image:
		you_lose_image.visible = false

	if result_restart_button:
		result_restart_button.visible = false
		result_restart_button.disabled = true

	if result_home_button:
		result_home_button.visible = false
		result_home_button.disabled = true

	if player_win_image:
		player_win_image.visible = true
		player_win_image.scale = Vector2(0.8, 0.8)

	if princess_win_image:
		princess_win_image.visible = true
		princess_win_image.scale = Vector2(0.8, 0.8)

	if next_button:
		next_button.visible = true
		next_button.disabled = false
		next_button.modulate.a = 1.0
		next_button.mouse_filter = Control.MOUSE_FILTER_STOP
		next_button.z_index = 60
		next_button.z_as_relative = false
		next_button.move_to_front()

	_show_ending_dialog_step()


func _show_ending_dialog_step() -> void:
	if ending_dialog_step == 0:
		if player_dialog_label:
			player_dialog_label.visible = true
			player_dialog_label.modulate.a = 0.0

		if princess_dialog_label:
			princess_dialog_label.visible = false

		var tween := create_tween()
		if player_dialog_label:
			tween.tween_property(player_dialog_label, "modulate:a", 1.0, 0.25)

	elif ending_dialog_step == 1:
		if player_dialog_label:
			player_dialog_label.visible = false

		if princess_dialog_label:
			princess_dialog_label.visible = true
			princess_dialog_label.modulate.a = 0.0

		var tween := create_tween()
		if princess_dialog_label:
			tween.tween_property(princess_dialog_label, "modulate:a", 1.0, 0.25)

	elif ending_dialog_step >= 2:
		_show_ending_final_win()


func _show_ending_final_win() -> void:
	if player_win_image:
		player_win_image.visible = false

	if princess_win_image:
		princess_win_image.visible = false

	if player_dialog_label:
		player_dialog_label.visible = false

	if princess_dialog_label:
		princess_dialog_label.visible = false

	if next_button:
		next_button.visible = false
		next_button.disabled = true

	if you_lose_image:
		you_lose_image.visible = false

	if you_win_image:
		you_win_image.visible = true
		you_win_image.scale = Vector2(0.4, 0.4)

	if result_restart_button:
		result_restart_button.visible = true
		result_restart_button.disabled = false
		result_restart_button.modulate.a = 1.0
		result_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		result_restart_button.z_index = 50
		result_restart_button.z_as_relative = false
		result_restart_button.move_to_front()
		result_restart_button.scale = Vector2(0.8, 0.8)

	if result_home_button:
		result_home_button.visible = true
		result_home_button.disabled = false
		result_home_button.modulate.a = 1.0
		result_home_button.mouse_filter = Control.MOUSE_FILTER_STOP
		result_home_button.z_index = 50
		result_home_button.z_as_relative = false
		result_home_button.move_to_front()
		result_home_button.scale = Vector2(0.8, 0.8)

	var tween := create_tween()

	if you_win_image:
		tween.tween_property(you_win_image, "scale", Vector2(1.1, 1.1), 0.25)
		tween.tween_property(you_win_image, "scale", Vector2(1.0, 1.0), 0.15)

	if result_restart_button:
		tween.tween_property(result_restart_button, "scale", Vector2(1.0, 1.0), 0.2)

	if result_home_button:
		tween.tween_property(result_home_button, "scale", Vector2(1.0, 1.0), 0.2)


func _on_next_button_pressed() -> void:
	_play_button_click()

	ending_dialog_step += 1
	_show_ending_dialog_step()


func _on_result_restart_pressed() -> void:
	_play_button_click()

	if result_screen:
		result_screen.visible = false

	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null

	if main_menu:
		main_menu.visible = false

	hud.visible = true

	level = 1
	PlayerStats.reset()
	_load_level(level)


func _on_result_home_pressed() -> void:
	_play_button_click()

	if result_screen:
		result_screen.visible = false

	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null

	level = 1
	PlayerStats.reset()

	_show_main_menu()


# -----------------------------
# LEVEL MANAGEMENT
# -----------------------------
func _load_level(level_number: int) -> void:
	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null

	var level_path = "res://scene/levels/level_%s.tscn" % level_number

	if not ResourceLoader.exists(level_path):
		print("Level tidak ditemukan: ", level_path)
		return

	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)


func _setup_level(level_root: Node) -> void:
	var player = level_root.get_node_or_null("Player")

	if player:
		hud.set_player(player)

		if player.has_signal("died"):
			if not player.died.is_connected(_on_player_died):
				player.died.connect(_on_player_died)
	else:
		print("Player tidak ditemukan di level!")

	var exit = level_root.get_node_or_null("Exit")
	if exit:
		if not exit.body_entered.is_connected(_on_exit_body_entered):
			exit.body_entered.connect(_on_exit_body_entered)
	else:
		print("Exit tidak ditemukan di level!")

	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			if enemy.has_signal("died"):
				if not enemy.died.is_connected(_on_enemy_died):
					enemy.died.connect(_on_enemy_died)

	var princess = level_root.get_node_or_null("TuanPutri")
	if princess:
		if princess.has_signal("player_reached_princess"):
			if not princess.player_reached_princess.is_connected(_on_player_reached_princess):
				princess.player_reached_princess.connect(_on_player_reached_princess)
		else:
			print("TuanPutri tidak punya signal player_reached_princess!")

	_update_exit_blocker()


# ------------------------------
# ENEMY CHECK
# ------------------------------
func _has_alive_enemies() -> bool:
	if current_level_root == null:
		return false

	var enemies = current_level_root.get_node_or_null("Enemies")
	if enemies == null:
		return false

	for enemy in enemies.get_children():
		if enemy.get("is_alive") == true:
			return true

	return false


func _update_exit_blocker() -> void:
	if current_level_root == null:
		return

	var blocker_collision = current_level_root.get_node_or_null("ExitBlocker/CollisionShape2D")
	if blocker_collision == null:
		return

	blocker_collision.disabled = not _has_alive_enemies()


# ------------------------------
# MENU BUTTON HANDLERS
# ------------------------------
func _on_start_button_pressed() -> void:
	_play_button_click()
	print("Start diklik")

	if is_starting_game:
		return

	if win_screen:
		win_screen.visible = false

	if result_screen:
		result_screen.visible = false

	_play_start_intro_transition()


func _on_settings_button_pressed() -> void:
	_play_button_click()
	print("Settings diklik")

	_stop_start_button_animation()

	if menu_buttons:
		menu_buttons.visible = false

	if settings_panel:
		settings_panel.visible = true
		if settings_panel is Control:
			settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if tutorial_panel:
		tutorial_panel.visible = false
		if tutorial_panel is Control:
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if credits_panel:
		credits_panel.visible = false
		if credits_panel is Control:
			credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if home_button:
		home_button.visible = true
		home_button.disabled = false


func _on_tutorial_button_pressed() -> void:
	_play_button_click()
	print("Tutorial diklik")

	_stop_start_button_animation()

	if menu_buttons:
		menu_buttons.visible = false

	if tutorial_panel:
		tutorial_panel.visible = true
		if tutorial_panel is Control:
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if settings_panel:
		settings_panel.visible = false
		if settings_panel is Control:
			settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if credits_panel:
		credits_panel.visible = false
		if credits_panel is Control:
			credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if home_button:
		home_button.visible = true
		home_button.disabled = false


func _on_credits_button_pressed() -> void:
	_play_button_click()
	print("Credits diklik")

	_stop_start_button_animation()

	if menu_buttons:
		menu_buttons.visible = false

	if credits_panel:
		credits_panel.visible = true
		if credits_panel is Control:
			credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if credits_panel.has_method("restart_credits"):
			credits_panel.restart_credits()

	if settings_panel:
		settings_panel.visible = false
		if settings_panel is Control:
			settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if tutorial_panel:
		tutorial_panel.visible = false
		if tutorial_panel is Control:
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if home_button:
		home_button.visible = true
		home_button.disabled = false


func _on_home_button_pressed() -> void:
	_play_button_click()
	print("Home diklik")

	if settings_panel:
		settings_panel.visible = false
		if settings_panel is Control:
			settings_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if tutorial_panel:
		tutorial_panel.visible = false
		if tutorial_panel is Control:
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if credits_panel:
		credits_panel.visible = false
		if credits_panel is Control:
			credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if menu_buttons:
		menu_buttons.visible = true

	if start_button:
		start_button.visible = true
		start_button.disabled = false

	if settings_button:
		settings_button.visible = true
		settings_button.disabled = false

	if tutorial_button:
		tutorial_button.visible = true
		tutorial_button.disabled = false

	if credits_button:
		credits_button.visible = true
		credits_button.disabled = false

	if home_button:
		home_button.visible = false

	_start_button_float()


# ------------------------------
# SETTINGS TOGGLE HANDLERS
# ------------------------------
func _on_music_toggle_pressed() -> void:
	_play_button_click()

	music_enabled = not music_enabled

	if music_toggle_button:
		music_toggle_button.text = "ON" if music_enabled else "OFF"

	var music_node = get_node_or_null("Music")
	if music_node:
		music_node.stream_paused = not music_enabled


func _on_sfx_toggle_pressed() -> void:
	_play_button_click()

	sfx_enabled = not sfx_enabled

	if sfx_toggle_button:
		sfx_toggle_button.text = "ON" if sfx_enabled else "OFF"


# ------------------------------
# GAME SIGNAL HANDLERS
# ------------------------------
func _on_enemy_died() -> void:
	_update_exit_blocker()


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if _has_alive_enemies():
		print("Habisi semua musuh dulu sebelum lanjut level!")
		return

	if level >= max_level:
		print("Semua level selesai!")
		_show_result_screen(true)
		return

	level += 1
	call_deferred("_load_level", level)


func _on_player_reached_princess() -> void:
	print("Player berhasil menyelamatkan Tuan Putri!")

	if _has_alive_enemies():
		print("Habisi semua musuh dulu sebelum menyelamatkan Tuan Putri!")
		return

	_show_ending_dialog()


func _on_start_again_pressed() -> void:
	_play_button_click()
	_restart_game()


func _restart_game() -> void:
	if win_screen:
		win_screen.visible = false

	if result_screen:
		result_screen.visible = false

	if main_menu:
		main_menu.visible = false

	hud.visible = true

	level = 1
	PlayerStats.reset()
	_load_level(level)


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	_show_result_screen(false)
