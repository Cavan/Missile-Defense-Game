extends Node2D

@onready var turret_sprite: Sprite2D = $TurretSprite

const PlayerProjectile = preload("res://scenes/player_projectile.tscn")

# Turret properties
var rotation_speed = PI * 2 # Radians per second for smoothing, can be adjusted
                           # Set to a high value for direct mouse follow initially
var can_shoot = true
var shoot_cooldown = 0.5 # Seconds
var shoot_timer = null

func _ready():
    # Load and set texture for TurretSprite
    var icon_tex = load("res://icon.svg")
    if turret_sprite and icon_tex:
        turret_sprite.texture = icon_tex
    elif not turret_sprite:
        printerr("TurretSprite node not found in turret.gd for icon assignment.")
    elif not icon_tex:
        printerr("Failed to load res://icon.svg in turret.gd.")

    # Timer for shoot cooldown
    shoot_timer = Timer.new()
    shoot_timer.wait_time = shoot_cooldown
    shoot_timer.one_shot = true # Only fire once per cooldown period
    shoot_timer.timeout.connect(_on_shoot_timer_timeout)
    add_child(shoot_timer)

func _process(delta):
    # Aiming: Make the turret point towards the mouse cursor
    var mouse_pos = get_global_mouse_position()
    look_at(mouse_pos) # Instantly points the turret towards the mouse

    # Shooting: Check for left mouse button click
    if Input.is_action_just_pressed("ui_accept") and can_shoot: # "ui_accept" is usually left mouse click or space
        _shoot()

func _shoot():
    if not can_shoot:
        return

    can_shoot = false
    shoot_timer.start()

    var projectile_instance = PlayerProjectile.instantiate()
    # Ensure the projectile is added to the main scene tree, not the turret itself,
    # so its movement isn't affected by turret rotation after firing.
    # We assume the turret is a child of the main game scene.
    if get_parent():
        get_parent().add_child(projectile_instance)
    else:
        push_warning("Turret has no parent, cannot add projectile to scene tree.")
        # Fallback: add to self, but this is not ideal
        # add_child(projectile_instance)
        # return

    # Start projectile at the TurretSprite's global position.
    # If TurretSprite is not found, default to turret's own global_position.
    var spawn_position = global_position
    var turret_sprite = get_node_or_null("TurretSprite")
    if turret_sprite:
        spawn_position = turret_sprite.global_position
    else:
        push_warning("TurretSprite node not found, projectile will spawn at Turret's origin.")

    projectile_instance.global_position = spawn_position
    projectile_instance.global_rotation = global_rotation # Align with turret's direction
    # The projectile's own script will handle its forward movement based on its rotation

func _on_shoot_timer_timeout():
    can_shoot = true
