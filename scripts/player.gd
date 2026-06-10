extends CharacterBody2D

signal health_changed(new_health: int)
signal died

const SPEED = 300.0

var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var alive: bool = true
var max_health: int
var health: int
var strength: int = 20

# Knockback player ketika terkena damage
var is_knockback: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@export var knockback_force: float = 450.0
@export var knockback_duration: float = 0.18

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = get_node_or_null("TakeDamage")
@onready var swing_sword_sound: AudioStreamPlayer2D = get_node_or_null("SwingSword")
@onready var hitbox: Area2D = $Hitbox
@onready var damage_cooldown: Timer = $DamageCooldown


func _ready() -> void:
	# Load health from singleton
	health = PlayerStats.health
	max_health = PlayerStats.max_health

	# Initialise hitbox offset
	hitbox_offset = hitbox.position


func _physics_process(delta: float) -> void:
	# Disable hitbox until an attack is triggered
	hitbox.monitoring = false

	if not alive:
		velocity = Vector2.ZERO
		return

	# Saat player kena damage, player akan terdorong ke belakang
	if is_knockback:
		velocity = knockback_velocity
		move_and_slide()

		knockback_timer -= delta
		if knockback_timer <= 0.0:
			is_knockback = false
			velocity = Vector2.ZERO

		return

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# Skip movement if attacking
	if is_attacking:
		velocity = Vector2.ZERO
		return

	process_movement()
	process_animation()
	move_and_slide()


# -------------------------
# MOVEMENT & ANIMATION
# -------------------------
func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if is_attacking:
		return

	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")


# -------------------------
# ATTACKING
# -------------------------
func attack() -> void:
	if not alive:
		return

	if is_knockback:
		return

	is_attacking = true
	hitbox.monitoring = true

	if swing_sword_sound:
		swing_sword_sound.play()

	play_animation("attack", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false


# -------------------------
# HITBOX OFFSET
# -------------------------
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y

	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(strength, global_position)


# -------------------------
# HEALTH
# -------------------------
func heal(amount: int) -> void:
	if not alive:
		return

	health += amount

	if health >= max_health:
		health = max_health

	PlayerStats.health = health
	emit_signal("health_changed", health)


func take_damage(amount: int, attacker_position: Vector2 = Vector2.INF) -> void:
	if not alive:
		return

	if damage_cooldown.time_left > 0:
		return

	if take_damage_sound:
		take_damage_sound.play()

	health -= amount
	PlayerStats.health = health
	emit_signal("health_changed", health)

	_apply_knockback(attacker_position)

	if health <= 0:
		die()
		return

	# Make player invincible for a short time
	damage_cooldown.start()


func _apply_knockback(attacker_position: Vector2) -> void:
	var knockback_direction: Vector2

	if attacker_position == Vector2.INF:
		knockback_direction = -last_direction.normalized()
	else:
		knockback_direction = (global_position - attacker_position).normalized()

	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.DOWN

	is_knockback = true
	knockback_timer = knockback_duration
	knockback_velocity = knockback_direction * knockback_force


func die() -> void:
	if not alive:
		return

	alive = false
	velocity = Vector2.ZERO
	is_knockback = false
	is_attacking = false
	hitbox.monitoring = false

	died.emit()

	if animated_sprite_2d and animated_sprite_2d.sprite_frames.has_animation("dying"):
		animated_sprite_2d.play("dying")
