extends CanvasLayer

@export var enemy_lines: Array[String] = [
	"Hahaha! Kamu berani masuk ke wilayahku?",
	"Kamu tidak akan bisa melewati pasukanku!"
]

@export var player_lines: Array[String] = [
	"Aku tidak akan mundur!",
	"Aku akan mengalahkan semua musuh di sini!"
]

@export var typing_speed: float = 0.035

@onready var control: Control = $Control
@onready var color_rect: ColorRect = $Control/ColorRect
@onready var enemy_image: TextureRect = $Control/EnemyImage
@onready var player_image: TextureRect = $Control/PlayerImage
@onready var dialog_bg: TextureRect = $Control/DialogBG
@onready var dialog_label: Label = $Control/DialogLabel
@onready var next_button: BaseButton = $Control/NextButton
@onready var conversation_sound: AudioStreamPlayer = $ConversationSound

var current_speaker: String = "enemy"
var current_line_index: int = 0
var is_typing: bool = false
var current_full_text: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if control:
		control.process_mode = Node.PROCESS_MODE_ALWAYS
		control.set_anchors_preset(Control.PRESET_FULL_RECT)

	if color_rect:
		color_rect.process_mode = Node.PROCESS_MODE_ALWAYS
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.color = Color(0, 0, 0, 0.0)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if enemy_image:
		enemy_image.process_mode = Node.PROCESS_MODE_ALWAYS
		enemy_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if player_image:
		player_image.process_mode = Node.PROCESS_MODE_ALWAYS
		player_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if dialog_bg:
		dialog_bg.process_mode = Node.PROCESS_MODE_ALWAYS
		dialog_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if dialog_label:
		dialog_label.process_mode = Node.PROCESS_MODE_ALWAYS
		dialog_label.text = ""

	if next_button:
		next_button.process_mode = Node.PROCESS_MODE_ALWAYS
		next_button.mouse_filter = Control.MOUSE_FILTER_STOP
		next_button.disabled = false

		if not next_button.pressed.is_connected(_on_next_button_pressed):
			next_button.pressed.connect(_on_next_button_pressed)

	show_intro()


func show_intro() -> void:
	visible = true
	get_tree().paused = true
	

	current_speaker = "enemy"
	current_line_index = 0
	is_typing = false
	current_full_text = ""

	if color_rect:
		color_rect.visible = true
		color_rect.modulate.a = 1.0
		color_rect.color = Color(0, 0, 0, 0.0)

	if enemy_image:
		enemy_image.visible = true
		enemy_image.modulate.a = 0.0
		enemy_image.scale = Vector2(0.4, 0.4)

	if player_image:
		player_image.visible = false
		player_image.modulate.a = 0.0
		player_image.scale = Vector2(0.4, 0.4)

	if dialog_bg:
		dialog_bg.visible = true
		dialog_bg.modulate.a = 0.0
		dialog_bg.scale = Vector2(0.8, 0.8)

	if dialog_label:
		dialog_label.visible = true
		dialog_label.modulate.a = 0.0
		dialog_label.text = ""

	if next_button:
		next_button.visible = false
		next_button.disabled = true
		next_button.modulate.a = 0.0

	await _play_popup_animation()
	_start_typing_current_line()


func _play_popup_animation() -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	if color_rect:
		tween.tween_property(color_rect, "color", Color(0, 0, 0, 0.5), 0.25)

	if enemy_image:
		tween.tween_property(enemy_image, "modulate:a", 1.0, 0.25)
		tween.tween_property(enemy_image, "scale", Vector2(1.1, 1.1), 0.25)

	if dialog_bg:
		tween.tween_property(dialog_bg, "modulate:a", 1.0, 0.25)
		tween.tween_property(dialog_bg, "scale", Vector2(1.05, 1.05), 0.25)

	if dialog_label:
		tween.tween_property(dialog_label, "modulate:a", 1.0, 0.25)

	await tween.finished

	var tween2 := create_tween()
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween2.set_parallel(true)

	if enemy_image:
		tween2.tween_property(enemy_image, "scale", Vector2(1.0, 1.0), 0.12)

	if dialog_bg:
		tween2.tween_property(dialog_bg, "scale", Vector2(1.0, 1.0), 0.12)

	await tween2.finished


func _start_typing_current_line() -> void:
	var lines := _get_current_lines()

	if lines.is_empty():
		_go_to_next_speaker_or_close()
		return

	if current_line_index >= lines.size():
		_go_to_next_speaker_or_close()
		return

	current_full_text = lines[current_line_index]
	_type_text(current_full_text)


func _get_current_lines() -> Array[String]:
	if current_speaker == "enemy":
		return enemy_lines

	return player_lines


func _type_text(text_to_type: String) -> void:
	is_typing = true

	if conversation_sound:
		conversation_sound.stop()
		conversation_sound.play()

	if next_button:
		next_button.visible = false
		next_button.disabled = true

	if dialog_label:
		dialog_label.text = ""

	for i in range(text_to_type.length()):
		if not is_typing:
			break

		if dialog_label:
			dialog_label.text = text_to_type.substr(0, i + 1)

		await get_tree().create_timer(typing_speed).timeout

	if dialog_label:
		dialog_label.text = text_to_type

	is_typing = false
	_show_next_button()


func _show_next_button() -> void:
	if next_button == null:
		return

	next_button.visible = true
	next_button.disabled = false
	next_button.modulate.a = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(next_button, "modulate:a", 1.0, 0.2)


func _on_next_button_pressed() -> void:
	if is_typing:
		is_typing = false

		if dialog_label:
			dialog_label.text = current_full_text

		if next_button:
			next_button.visible = true
			next_button.disabled = false
			next_button.modulate.a = 1.0

		return

	current_line_index += 1

	var lines := _get_current_lines()

	if current_line_index >= lines.size():
		_go_to_next_speaker_or_close()
		return

	_start_typing_current_line()


func _go_to_next_speaker_or_close() -> void:
	if current_speaker == "enemy":
		current_speaker = "player"
		current_line_index = 0
		await _switch_to_player()
		_start_typing_current_line()
		return

	_close_intro()


func _switch_to_player() -> void:
	if next_button:
		next_button.visible = false
		next_button.disabled = true

	if dialog_label:
		dialog_label.text = ""

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	if enemy_image:
		tween.tween_property(enemy_image, "modulate:a", 0.0, 0.18)
		tween.tween_property(enemy_image, "scale", Vector2(0.8, 0.8), 0.18)

	await tween.finished

	if enemy_image:
		enemy_image.visible = false

	if player_image:
		player_image.visible = true
		player_image.modulate.a = 0.0
		player_image.scale = Vector2(0.4, 0.4)

	var tween2 := create_tween()
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween2.set_parallel(true)

	if player_image:
		tween2.tween_property(player_image, "modulate:a", 1.0, 0.25)
		tween2.tween_property(player_image, "scale", Vector2(1.1, 1.1), 0.25)

	await tween2.finished

	var tween3 := create_tween()
	tween3.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if player_image:
		tween3.tween_property(player_image, "scale", Vector2(1.0, 1.0), 0.12)

	await tween3.finished


func _close_intro() -> void:
	if next_button:
		next_button.visible = false
		next_button.disabled = true

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	if color_rect:
		tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)

	if enemy_image:
		tween.tween_property(enemy_image, "modulate:a", 0.0, 0.2)
		tween.tween_property(enemy_image, "scale", Vector2(0.8, 0.8), 0.2)

	if player_image:
		tween.tween_property(player_image, "modulate:a", 0.0, 0.2)
		tween.tween_property(player_image, "scale", Vector2(0.8, 0.8), 0.2)

	if dialog_bg:
		tween.tween_property(dialog_bg, "modulate:a", 0.0, 0.2)
		tween.tween_property(dialog_bg, "scale", Vector2(0.8, 0.8), 0.2)

	if dialog_label:
		tween.tween_property(dialog_label, "modulate:a", 0.0, 0.2)

	await tween.finished
	
	if conversation_sound:
		conversation_sound.stop()

	get_tree().paused = false
	visible = false
