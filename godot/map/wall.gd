class_name Wall
extends Node3D

@export var shelve: Node3D
@export var enable_shelve := false:
	set(v):
		enable_shelve = v
		shelve.visible = enable_shelve
		
func _ready() -> void:
	self.enable_shelve = enable_shelve
