extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var current_sens = 0.08
var damage_indicator_target = null
@onready var head_pivot = $Head_Pivot
@onready var damage_indicator_look_at = $Damage_Indicator_LookAt
@onready var damage_indicator = $Fullscreen_UI/Screen_Center/Damage_Indicator

""""""
@onready var Cursor = load("res://line_2d.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * current_sens))
		head_pivot.rotate_x(deg_to_rad(-event.relative.y * current_sens))
		head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	"""
	if damage_indicator_target != null:
		damage_indicator.visible = true
		damage_indicator_look_at.look_at(damage_indicator_target.global_transform.origin, Vector3.UP)
		damage_indicator.rotation = -damage_indicator_look_at.rotation.y
	else:
		damage_indicator.visible = false
	"""
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	
	move_and_slide()
	
	"""This thing updates the cursors now and then. Maybe you should tie this to a timer or function of some sort so it doesn't have to run constantly... It maybe expensive!!!"""
	update_rotation()

func damage(body):
	damage_indicator_target = body
	
	var Sprite2d = $Fullscreen_UI/Screen_Center/Damage_Indicator
	var NewCursor = Cursor.instantiate() # Create a new Sprite2D.
	
	Sprite2d.add_child(NewCursor) # Add it as a child of this node.
	
	NewCursor.position = Vector2(0,0)
	
	
	print_debug("New cursor created by the name of:", NewCursor,"Created by", body)
	NewCursor.set_meta("enemyToLookAt", body)
	
	"""Let's force it to position up properly!"""
	update_rotation()

"""
obj.set_meta("key",value)
obj.has_meta("key")
obj.get_meta("key")
"""

func remove(body):
	print_debug("Existing cursor attempting removal, which was created by", body)
	var Sprite2d = $Fullscreen_UI/Screen_Center/Damage_Indicator
	
	for PreExistingCursor in Sprite2d.get_children():
		var checkThisDude = PreExistingCursor.get_meta("enemyToLookAt")
		if checkThisDude == body:
			PreExistingCursor.queue_free()

func update_rotation():
	var Sprite2d = $Fullscreen_UI/Screen_Center/Damage_Indicator
	
	for PreExistingCursor in Sprite2d.get_children():
		var enemyToLookAt = PreExistingCursor.get_meta("enemyToLookAt")
		damage_indicator_look_at.look_at(enemyToLookAt.global_transform.origin, Vector3.UP)
		PreExistingCursor.rotation = -damage_indicator_look_at.rotation.y
