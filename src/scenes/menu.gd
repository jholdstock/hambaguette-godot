extends Node

const menuTextTempl := """[center]Up/down to set difficulty: %s
L to toggle lettuce: %s
W to toggle walls: %s

SPACE to begin[/center]
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	draw()

func draw():
	$MenuText.text = menuTextTempl % [
		global.opts.difficulty,
		" on" if global.opts.lettuce else "off",
		# " on" for wraparound contains a weird unicode thin-space " " for lazy alignment.
		" on" if global.opts.wraparound else "off"
	]
	
# Called every frame. delta is the elapsed time since the previous frame.
func _process(_delta):
	keys.listen()

	match keys.pressed():
		keys.Key.CANCEL:
			get_tree().quit()
		keys.Key.UP:
			if global.opts.difficulty < global.cfg.MAX_DIFFICULTY:
				global.opts.difficulty = global.opts.difficulty+1
				draw()
		keys.Key.DOWN:
			if global.opts.difficulty > global.cfg.MIN_DIFFICULTY:
				global.opts.difficulty = global.opts.difficulty-1
				draw()
		keys.Key.W:
			global.opts.wraparound = !global.opts.wraparound
			draw()
		keys.Key.L:
			global.opts.lettuce = !global.opts.lettuce
			draw()
		keys.Key.ACCEPT:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
