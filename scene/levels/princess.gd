extends Area2D

signal player_reached_princess

@export var trigger_distance: float = 70.0

var already_triggered: bool = false


func _ready() -> void:
	print("Princess ready")

	monitoring = true
	monitorable = true

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	if already_triggered:
		return

	var player = get_parent().get_node_or_null("Player")

	if player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player <= trigger_distance:
		_trigger_princess()


func _on_body_entered(body: Node2D) -> void:
	print("Ada body masuk ke TuanPutri: ", body.name)

	if already_triggered:
		return

	if body.name == "Player":
		_trigger_princess()


func _trigger_princess() -> void:
	already_triggered = true
	print("Player menyentuh / mendekati TuanPutri")
	player_reached_princess.emit()
