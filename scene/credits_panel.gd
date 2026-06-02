extends Control

@export var scroll_speed: float = 40.0

@onready var credits_area: Control = $CreditsArea
@onready var credits_text: RichTextLabel = $CreditsArea/CreditsText


func _ready() -> void:
	credits_area.clip_contents = true
	restart_credits()


func _process(delta: float) -> void:
	if not visible:
		return

	# Credits bergerak ke atas
	credits_text.position.y -= scroll_speed * delta

	# Kalau teks sudah habis lewat atas, ulang dari bawah
	if credits_text.position.y + credits_text.size.y < 0:
		restart_credits()


func restart_credits() -> void:
	await get_tree().process_frame
	credits_text.position.y = credits_area.size.y
