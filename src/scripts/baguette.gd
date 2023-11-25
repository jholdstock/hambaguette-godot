class_name Baguette

var segments:Array[BaguetteSegment]
var currentDir := Vector2.RIGHT
var dead := false
var visible := true

func _init():
	var y := global.cfg.START_HEIGHT
	segments.append(BaguetteSegment.new(Vector2(4, y), Vector2.RIGHT))
	segments.append(BaguetteSegment.new(Vector2(3, y), Vector2.RIGHT))
	segments.append(BaguetteSegment.new(Vector2(2, y), Vector2.RIGHT))

func changeDir(newDir:Vector2):
	if currentDir + newDir != Vector2.ZERO:
		currentDir = newDir
		
func nextHeadPos(walls:bool) -> Vector2:
	var currentHeadPos := segments[0].pos
	var newHeadPos := currentHeadPos + currentDir
	if (walls == false):
		var posX := newHeadPos.x
		var posY := newHeadPos.y
		if (posX >= global.cfg.GRID_WIDTH):
			newHeadPos.x = 0
		elif (posX < 0):
			newHeadPos.x = global.cfg.GRID_WIDTH-1
		elif (posY >= global.cfg.GRID_HEIGHT):
			newHeadPos.y = 0
		elif (posY < 0):
			newHeadPos.y = global.cfg.GRID_HEIGHT-1
	return newHeadPos

func move(foodEaten:bool, walls:bool):
	addNewHead(walls)

	if (!foodEaten):
		removeTail()

func addNewHead(walls:bool):
	var newHeadPos := nextHeadPos(walls)
	var newHead := BaguetteSegment.new(newHeadPos, currentDir)
	segments.push_front(newHead)

func removeTail():
	segments.pop_back()
		
func checkForCollisions(walls:bool, lettuces:Array[Vector2]):
	var newHead := nextHeadPos(walls)

	checkForCollisionWithSelf(newHead)
	checkForCollisionWithLettuces(newHead, lettuces)
	
	if walls:
		checkForCollisionWithWalls(newHead)


func checkForCollisionWithWalls(newHeadPos:Vector2):
	var x := newHeadPos.x
	var y := newHeadPos.y
	if (x < 0 || y < 0 || x >= global.cfg.GRID_WIDTH || y >= global.cfg.GRID_HEIGHT):
		dead = true

func checkForCollisionWithLettuces(newHeadPos:Vector2, lettuces:Array[Vector2]):
	for l in lettuces:
		if (newHeadPos == l):
			dead = true;

func checkForCollisionWithSelf(newHeadPos:Vector2):
	for seg in segments:
		if newHeadPos == seg.pos:
			dead = true;
