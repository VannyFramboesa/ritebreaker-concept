extends Pickups
class_name Soul

@export var XP: float

func activate():
	super.activate()
	prints("+" + str(XP) + "XP")
