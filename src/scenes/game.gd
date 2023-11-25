extends Node

var baguette:Baguette

const LEFTEND := 0
const HORIZONTAL := 1
const RIGHTEND := 2
const TOPEND := 3
const BOTTOMRIGHT := 4
const BOTTOMLEFT := 5
const LETTUCE := 6
const VERTICAL := 7
const TOPRIGHT := 8
const TOPLEFT := 9
const HAM := 10
const BOTTOMEND := 11

var grid := []
var points:int = 0

var lettuces:Array[Vector2]
var ham:Vector2

var lastTime:float = 0

enum { PLAYING, GAMEOVER, FLASHING }
var state := PLAYING

var flashCounter := 0
var currentRefreshRate:float

# Called when the node enters the scene tree for the first time.
func _ready():
	var ts := 16 # Size of tiles in spritesheet is 1.
	var spritesheet := preload("res://scenes/sprites.tscn")
	for x in global.cfg.GRID_WIDTH:
		grid.append([])
		for y in global.cfg.GRID_HEIGHT:
			var tile := spritesheet.instantiate()
			tile.offset = Vector2((x*ts)+ts, (y*ts)+ts)
			tile.visible = false
			grid[x].append(tile)
			add_child(tile)

	baguette = Baguette.new()
	if global.opts.lettuce:
		createLettuce()

	createHam()

	currentRefreshRate = global.cfg.REFRESH_RATE * 2 - (0.025 * global.opts.difficulty)

	draw()

func randomLettuce() -> Vector2:
	# To avoid the game ending immediately, don't put lettuce on starting row.
	# To avoid unobtainable hams, don't put lettuce on outside edges.
	var xPos := randi_range(1, global.cfg.GRID_WIDTH-2)
	var yPos := 0
	while true:
		yPos = randi_range(1, global.cfg.GRID_HEIGHT-2)
		if yPos == global.cfg.START_HEIGHT:
			continue
		break
	return Vector2(xPos, yPos)

func createLettuce():
	var one := randomLettuce()
	var two := randomLettuce()
	while one == two:
		two = randomLettuce()
	lettuces.append(one)
	lettuces.append(two)

func createHam():
	# Ensure ham is not overlapping with lettuce or baguette.
	var pos:Vector2
	var overlap := true
	while overlap:
		overlap = false
		var x := randi_range(0, global.cfg.GRID_WIDTH-1)
		var y := randi_range(0, global.cfg.GRID_HEIGHT-1)
		pos = Vector2(x, y)
		for seg in baguette.segments:
			if pos == seg.pos:
				overlap = true
		for l in lettuces:
			if pos == l:
				overlap = true
	ham = pos

# Called every frame. delta is the elapsed time since the previous frame.
func _process(delta):
	keys.listen()

	if delta + lastTime >= currentRefreshRate:
		updateGame()
		draw()
		lastTime = 0
	else:
		lastTime += delta

func updateGame():
	match state:
		PLAYING:
			match keys.pressed():
				keys.Key.UP:
					baguette.changeDir(Vector2.UP)
				keys.Key.DOWN:
					baguette.changeDir(Vector2.DOWN)
				keys.Key.LEFT:
					baguette.changeDir(Vector2.LEFT)
				keys.Key.RIGHT:
					baguette.changeDir(Vector2.RIGHT)

			baguette.checkForCollisions(global.opts.wraparound, lettuces)
			if baguette.dead:
				currentRefreshRate = global.cfg.REFRESH_RATE
				state = FLASHING
				$DeathSound.play()
			else:
				var hamEaten := false
				if baguette.nextHeadPos(global.opts.wraparound) == ham:
					hamEaten = true
					points = points + global.opts.difficulty
					$PickupSound.play()
				baguette.move(hamEaten, global.opts.wraparound)

				if hamEaten:
					createHam()
		FLASHING:
			if flashCounter < 8:
				baguette.visible = !baguette.visible
				flashCounter += 1
			else:
				state = GAMEOVER
		GAMEOVER:
			$Gameover.visible = true
			match keys.pressed():
				keys.Key.ACCEPT:
					get_tree().change_scene_to_file("res://scenes/menu.tscn")


func draw():
	# Reset.
	for x in global.cfg.GRID_WIDTH:
		for y in global.cfg.GRID_HEIGHT:
			grid[x][y].visible = false

	# Draw Ham.
	grid[ham.x][ham.y].visible = true
	grid[ham.x][ham.y].frame = HAM

	# Draw Lettuces.
	for i in lettuces:
		grid[i.x][i.y].visible = true
		grid[i.x][i.y].frame = LETTUCE

	# Draw points.
	$PointsLabel.text = "POINTS: %d" % points
			
	# Draw baguette
	if baguette.visible:
		for i in baguette.segments.size():
			var seg := baguette.segments[i]
			grid[seg.pos.x][seg.pos.y].visible = true
			grid[seg.pos.x][seg.pos.y].frame = spriteForSegment(i, baguette.segments)

func spriteForSegment(posInBaguette:int, segments:Array[BaguetteSegment]) -> int:
		var direction := segments[posInBaguette].dir
		if (posInBaguette == 0): # Head
			if (direction == Vector2.UP):
				return TOPEND;
			elif (direction == Vector2.DOWN):
				return BOTTOMEND;
			elif (direction == Vector2.LEFT):
				return LEFTEND;
			else:
				return RIGHTEND;
		elif (posInBaguette == segments.size() - 1): # Tail
			var previousDirection := segments[posInBaguette - 1].dir
			if (previousDirection == Vector2.UP):
				return BOTTOMEND;
			elif (previousDirection == Vector2.DOWN):
				return TOPEND;
			elif (previousDirection == Vector2.LEFT):
				return RIGHTEND;
			else:
				return LEFTEND;
		else: # Any other segment
			var firstDirection := segments[posInBaguette - 1].dir
			if ((firstDirection == Vector2.UP && direction == Vector2.UP) 
					|| (firstDirection == Vector2.DOWN && direction == Vector2.DOWN)):
				return VERTICAL;
			elif ((firstDirection == Vector2.LEFT && direction == Vector2.LEFT)
					|| (firstDirection == Vector2.RIGHT && direction == Vector2.RIGHT)):
				return HORIZONTAL;
			elif ((firstDirection == Vector2.RIGHT && direction == Vector2.UP)
					|| (firstDirection == Vector2.DOWN && direction == Vector2.LEFT)):
				return BOTTOMRIGHT;
			elif ((firstDirection == Vector2.LEFT && direction == Vector2.UP)
					|| (firstDirection == Vector2.DOWN && direction == Vector2.RIGHT)):
				return BOTTOMLEFT;
			elif ((firstDirection == Vector2.RIGHT && direction == Vector2.DOWN)
					|| (firstDirection == Vector2.UP && direction == Vector2.LEFT)):
				return TOPRIGHT;
			else:
				return TOPLEFT;
