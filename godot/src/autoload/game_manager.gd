extends Node

signal logged(txt)
signal money_changed(m)

var menu := [PotionItem.Type.POTION_RED]
var money := 0:
	set(v):
		money = v
		money_changed.emit(v)

func _ready() -> void:
	money = 0
