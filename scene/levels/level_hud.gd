extends CanvasLayer

@export var map_name: String = "Nama Map"

@onready var map_name_label: Label = $MapNameBG/MapNameLabel
@onready var enemy_counter_label: Label = $EnemyCounterBG/EnemyCounterLabel

var total_enemies: int = 0
var defeated_enemies: int = 0


func _ready() -> void:
	map_name_label.text = map_name

	await get_tree().process_frame

	var level_root = get_parent()
	var enemies_node = level_root.get_node_or_null("Enemies")

	if enemies_node == null:
		print("Node Enemies tidak ditemukan!")
		_update_enemy_counter()
		return

	total_enemies = enemies_node.get_child_count()
	defeated_enemies = 0

	for enemy in enemies_node.get_children():
		if enemy.has_signal("died"):
			if not enemy.died.is_connected(_on_enemy_died):
				enemy.died.connect(_on_enemy_died)
		else:
			print(enemy.name, " tidak punya signal died")

	_update_enemy_counter()


func _on_enemy_died() -> void:
	defeated_enemies += 1
	defeated_enemies = clamp(defeated_enemies, 0, total_enemies)
	_update_enemy_counter()


func _update_enemy_counter() -> void:
	enemy_counter_label.text = str(defeated_enemies) + "/" + str(total_enemies)
