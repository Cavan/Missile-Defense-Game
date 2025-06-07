extends Node2D

# Preload the enemy missile scene
const EnemyMissile = preload("res://scenes/enemy_missile.tscn")

# Game state
var score = 0
var lives = 3
var game_is_over = false
var spawn_interval = 2.0 # Seconds for missile spawning

# UI Reference
@onready var game_ui_instance = $GameUI_Instance # Path to the instanced UI scene

# Timer for spawning missiles - will be initialized in _ready
var missile_spawn_timer = null

func _ready():
    add_to_group("main_game_group") # Add MainGame to a group for projectiles to call

    # Configure background to fill screen
    var viewport_rect = get_viewport_rect()
    if $Background: # Check if Background node exists
         $Background.size = viewport_rect.size
    else:
        push_warning("Background node not found in MainGame.")


    # Position turret (example: bottom center)
    if $PlayerTurret:
        $PlayerTurret.position = Vector2(viewport_rect.size.x / 2, viewport_rect.size.y - 50)
    else:
        push_warning("PlayerTurret node not found in MainGame.")

    # Initialize UI
    if game_ui_instance:
        game_ui_instance.update_score(score)
        game_ui_instance.update_lives(lives)
    else:
        push_warning("GameUI_Instance not found in MainGame. UI will not be updated.")

    _start_missile_spawning()


func _start_missile_spawning():
    # Setup timer for spawning enemy missiles
    # This reuses the class member `missile_spawn_timer`
    missile_spawn_timer = Timer.new()
    missile_spawn_timer.name = "DynamicMissileSpawnTimer" # Optional: good for debugging
    missile_spawn_timer.wait_time = spawn_interval
    missile_spawn_timer.one_shot = false # Make it repeat
    missile_spawn_timer.timeout.connect(_on_missile_spawn_timer_timeout)
    add_child(missile_spawn_timer) # Add to scene tree so it processes
    missile_spawn_timer.start()

    # Spawn one immediately for testing, only if game is not over
    if not game_is_over:
        _spawn_enemy_missile()


func _on_missile_spawn_timer_timeout():
    if game_is_over:
        return
    _spawn_enemy_missile()

func _spawn_enemy_missile():
    if game_is_over: # Should not happen if timer is stopped, but as a safeguard
        return

    var viewport_rect = get_viewport_rect()
    var new_missile = EnemyMissile.instantiate()

    var spawn_x = randf_range(0, viewport_rect.size.x)
    new_missile.position = Vector2(spawn_x, 0)

    # Connect the missile_leaked signal from the new missile instance
    if new_missile.is_connected("missile_leaked", Callable(self, "_on_missile_leaked")):
        push_warning("Signal 'missile_leaked' may already be connected or an error in logic.")
    else:
        var error_code = new_missile.connect("missile_leaked", Callable(self, "_on_missile_leaked"))
        if error_code != OK:
            push_error("Failed to connect missile_leaked signal. Error code: " + str(error_code))

    add_child(new_missile)

# This function will be called by PlayerProjectile via group call
func award_score(points):
    if game_is_over:
        return
    score += points
    if game_ui_instance:
        game_ui_instance.update_score(score)
    else:
        push_warning("GameUI_Instance not found. Score UI not updated.")


func _on_missile_leaked():
    if game_is_over: # Don't process if game already ended
        return

    lives -= 1
    if game_ui_instance:
        game_ui_instance.update_lives(lives)
    else:
        push_warning("GameUI_Instance not found. Lives UI not updated.")

    if lives <= 0 and not game_is_over: # Ensure _game_over is called only once
        _game_over()

func _game_over():
    if game_is_over: # Prevent multiple executions
        return
    game_is_over = true

    print("GAME OVER") # For console debugging

    if missile_spawn_timer != null && missile_spawn_timer.is_inside_tree():
        missile_spawn_timer.stop()
        # Consider queue_free() for the timer if game can be restarted, to avoid multiple timers

    # Optional: Display a game over message on the existing UI
    if game_ui_instance and game_ui_instance.has_method("show_game_over_message"):
        game_ui_instance.show_game_over_message()
    else:
        # Simple pause, a dedicated game over screen would be better
        push_warning("GameUI_Instance does not have show_game_over_message or is null. Pausing tree.")
        get_tree().paused = true

func _process(delta):
    # Main game loop logic will go here later
    pass
