extends Area2D

# signal enemy_destroyed(points) # Removed, using group call instead

var speed = 600
var points_for_kill = 100 # Points awarded for destroying a missile

func _ready():
    add_to_group("player_projectiles")
    area_entered.connect(_on_area_entered)


func _process(delta):
    var forward_direction = Vector2.UP.rotated(global_rotation)
    position += forward_direction * speed * delta

    # Remove projectile if it goes too far off screen
    var viewport_rect = get_viewport_rect()
    # Check a larger boundary than the viewport itself to ensure it's truly off-screen
    if not Rect2(viewport_rect.position - Vector2(50,50), viewport_rect.size + Vector2(100,100)).has_point(global_position):
        queue_free()

func _on_area_entered(area):
    if area.is_in_group("enemy_missiles"):
        # Call main_game to award score
        get_tree().call_group("main_game_group", "award_score", points_for_kill)

        if area.has_method("queue_free"):
            area.queue_free()
        if self.has_method("queue_free"):
            queue_free()
