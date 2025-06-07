extends Control

# References to the labels, assign in the editor or via code
@onready var score_label: Label = $MarginContainer/TopBar/ScoreLabel
@onready var lives_label: Label = $MarginContainer/TopBar/LivesLabel

func update_score(new_score):
    if score_label:
        score_label.text = "Score: " + str(new_score)

func update_lives(new_lives):
    if lives_label:
        lives_label.text = "Lives: " + str(new_lives)

func _ready():
    # Initialize with default values (or values from a game manager)
    # These will be updated by MainGame when it's ready
    update_score(0) # Score and lives will be set by MainGame shortly after this.
    update_lives(3)

func show_game_over_message():
    var go_label = Label.new()
    go_label.text = "GAME OVER"

    # Attempt to make it somewhat visible. A proper theme or font resource is better.
    go_label.set_anchors_preset(Control.PRESET_CENTER)
    go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    go_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER # Ensure vertical centering

    # Style it a bit (can be improved with themes)
    go_label.modulate = Color.RED
    # Example of trying to set font size - this requires a Font resource
    # var font = FontFile.new() # This is abstract, need concrete like FontVariation or SystemFont
    # font.font_path = "res://path_to_font.ttf" # if you have a font
    # font.font_size = 48
    # go_label.add_theme_font_override("font", font)
    # go_label.add_theme_font_size_override("font_size", 48) # More direct for some themes

    # For simplicity without external fonts, rely on scaling or default font visibility.
    # Consider placing it in a new container that is centered if PRESET_CENTER isn't enough
    # due to parent container configurations.

    add_child(go_label) # Add it to the GameUI scene's root (Control node)

    # Ensure it's on top if other UI elements could overlap
    go_label.z_index = 100 # Or move_to_front() if parent allows sorting children manually.
    go_label.move_to_front()
