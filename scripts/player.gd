extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 320.0
const JUMP_VELOCITY = -610.0

# Set this in the Inspector to your level start position
@export var spawn_point: Vector2 = Vector2.ZERO

# Current active checkpoint
var current_checkpoint: Vector2


func _ready():
	await get_tree().process_frame
	
	# Start at spawn
	current_checkpoint = spawn_point
	global_position = current_checkpoint
	
	await get_tree().physics_frame
	velocity = Vector2.ZERO
	move_and_slide()


func _physics_process(delta: float) -> void:

	# Apply gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		animated_sprite_2d.animation = "jumping"
	else:
		if abs(velocity.x) > 1:
			animated_sprite_2d.animation = "running"
		else:
			animated_sprite_2d.animation = "idle"

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# Flip sprite
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true


# ==========================
# 💀 KILL BRICK
# ==========================

func _on_kill_brick_body_entered(body: Node2D) -> void:
	if body == self:
		die()


func die():
	velocity = Vector2.ZERO
	
	# Respawn at latest checkpoint
	global_position = current_checkpoint
	
	await get_tree().physics_frame
	move_and_slide()


# ==========================
# 🟢 CHECKPOINT SYSTEM
# ==========================

func set_checkpoint(new_position: Vector2):
	current_checkpoint = new_position
	print("Checkpoint activated at:", new_position)


func _on_check_point_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
