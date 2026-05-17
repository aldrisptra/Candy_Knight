extends Node2D

@onready var hud: CanvasLayer = $HUD

var win_screen: CanvasLayer
var win_control: Control
var win_label: Label
var start_again_button: Button
var win_color_rect: ColorRect

var level: int = 1
var max_level: int = 3
var current_level_root: Node = null


func _ready() -> void:
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
		
		if win_label:
			win_label.text = "CONGRATS!"
			win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			win_label.add_theme_color_override("font_color", Color.WHITE)
		else:
			print("Node Label tidak ditemukan di dalam WinScreen!")
		
		if start_again_button:
			start_again_button.text = "Start Again"
			start_again_button.pressed.connect(_on_start_again_pressed)
		else:
			print("Node Button tidak ditemukan di dalam WinScreen!")
	else:
		print("Node WinScreen tidak ditemukan!")

	current_level_root = get_node_or_null("LevelRoot")
	_load_level(level)


#-----------------------------
# LEVEL MANAGEMENT
#-----------------------------
func _load_level(level_number: int) -> void:
	if current_level_root:
		current_level_root.queue_free()
		
	var level_path = "res://scene/levels/level_%s.tscn" % level_number
	
	if not ResourceLoader.exists(level_path):
		print("Level tidak ditemukan: ", level_path)
		return
	
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)


func _setup_level(level_root: Node) -> void:
	var player = level_root.get_node("Player")
	$HUD.set_player(player)
	player.died.connect(_on_player_died)
	
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)

	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			if enemy.has_signal("died"):
				enemy.died.connect(_on_enemy_died)

	_update_exit_blocker()


#------------------------------
# ENEMY CHECK
#------------------------------
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


#------------------------------
# WIN SCREEN
#------------------------------
func _show_win_screen() -> void:
	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null

	hud.visible = false

	if win_screen == null:
		print("WinScreen belum ada, tidak bisa menampilkan layar menang.")
		return

	win_screen.visible = true

	if win_control:
		win_control.modulate.a = 0.0

	if win_label:
		win_label.scale = Vector2(0.3, 0.3)

	if start_again_button:
		start_again_button.scale = Vector2(0.3, 0.3)

	var tween = create_tween()
	
	if win_control:
		tween.tween_property(win_control, "modulate:a", 1.0, 0.5)
	
	if win_label:
		tween.tween_property(win_label, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_property(win_label, "scale", Vector2(1.0, 1.0), 0.2)
	
	if start_again_button:
		tween.tween_property(start_again_button, "scale", Vector2(1.0, 1.0), 0.3)


func _restart_game() -> void:
	if win_screen:
		win_screen.visible = false
	
	hud.visible = true
	
	level = 1
	PlayerStats.reset()
	_load_level(level)


#------------------------------
# SIGNAL HANDLERS
#------------------------------
func _on_enemy_died() -> void:
	_update_exit_blocker()


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if _has_alive_enemies():
		print("Habisi semua slime dulu sebelum lanjut level!")
		return

	if level >= max_level:
		print("Semua level selesai!")
		_show_win_screen()
		return

	level += 1
	call_deferred("_load_level", level)


func _on_start_again_pressed() -> void:
	_restart_game()


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	await hud.fade(1.0)
	
	level = 1
	PlayerStats.reset()
	_load_level(level)
	
	await hud.fade(0.0)
