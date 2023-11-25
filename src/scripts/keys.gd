extends Node

enum Key { UP, DOWN, LEFT, RIGHT, W, L, ACCEPT, CANCEL, NONE }
var lastPress := Key.NONE

func pressed() -> keys.Key:
	var p := lastPress
	lastPress = Key.NONE
	return p

func listen():
	if Input.is_action_just_pressed("ui_up"):
		lastPress = Key.UP
		return
	if Input.is_action_just_pressed("ui_down"):
		lastPress = Key.DOWN
		return
	if Input.is_action_just_pressed("ui_left"):
		lastPress = Key.LEFT
		return
	if Input.is_action_just_pressed("ui_right"):
		lastPress = Key.RIGHT
		return
	if Input.is_action_just_pressed("jh_w"):
		lastPress = Key.W
		return
	if Input.is_action_just_pressed("jh_l"):
		lastPress = Key.L
		return
	if Input.is_action_just_pressed("ui_accept"):
		lastPress = Key.ACCEPT
		return
	if Input.is_action_just_pressed("ui_cancel"):
		lastPress = Key.CANCEL
		return
