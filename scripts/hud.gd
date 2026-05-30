extends CanvasLayer

const HEART_SIZE: int = 20

var player

const HEART_FULL = preload("res://assets/images/UI/Heart_full.png")
const HEART_HALF = preload("res://assets/images/UI/Heart_half.png")
const HEART_EMPTY = preload("res://assets/images/UI/Heart_empty.png")

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var hearts_container: HBoxContainer = $Hearts


func set_player(p) -> void:
	player = p
	
	if player:
		player.health_changed.connect(_update_health)
		_update_health(player.health)
	

func _update_health(new_health: int) -> void:
	var hearts = hearts_container.get_children()
	var max_hearts: int = hearts.size()
	var hp: int = max(new_health, 0)

	var full: int = clampi(floori(float(hp) / float(HEART_SIZE)), 0, max_hearts)
	var has_half: bool = false

	if full < max_hearts and hp % HEART_SIZE > 0:
		has_half = true

	for i in range(max_hearts):
		if i < full:
			hearts[i].texture = HEART_FULL
		elif i == full and has_half:
			hearts[i].texture = HEART_HALF
		else:
			hearts[i].texture = HEART_EMPTY


func fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", to_alpha, 1.5)
	await tween.finished
