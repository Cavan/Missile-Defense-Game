extends Area2D

signal missile_leaked # New signal

var speed = 200
var target_direction = Vector2.DOWN

func _ready():
    rotation = target_direction.angle() + PI/2
    add_to_group("enemy_missiles")

func _process(delta):
    position += target_direction * speed * delta

    var viewport_rect = get_viewport_rect()
    if global_position.y > viewport_rect.size.y + 50: # 50 is a small buffer
        missile_leaked.emit() # Emit signal
        queue_free()
        # Later, this is where we would signal that a missile hit the base/ground
        # get_tree().call_group("game_manager", "missile_leaked")


# Optional:
# func _on_area_entered(area):
#     # Example: if missile hits something else other than player projectile
#     if area.is_in_group("player_base"): # Assuming player_base is another Area2D or RigidBody2D
#         print("Enemy missile hit the player base!")
#         queue_free()
#     # Collision with "player_projectiles" is handled by the projectile itself.
#     pass
