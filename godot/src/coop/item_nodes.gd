class_name ItemNodes
extends Node3D

@export var item_node: Node3D

@onready var item: CSGBox3D = $Item
@onready var cauldron: CSGBox3D = $Cauldron

func show_item(i, hide_others = true):
	if hide_others:
		hide_all()
	get_node_for_item(i).show()

func get_node_for_item(i):
	if i is GridItem:
		return cauldron
	
	return item_node

func hide_all():
	for c in get_children():
		c.hide()
