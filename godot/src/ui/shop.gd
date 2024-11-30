class_name Shop
extends Control

@export var container: Control
@export var item_scene: PackedScene
@export var item_count := 3

func _ready() -> void:
	hide()
	focus_exited.connect(func(): hide())

func open_shop():
	for c in container.get_children():
		c.queue_free()
		
	var items = []
	var available = ShopItem.Item.values()
	for i in range(item_count):
		var type = available.pick_random()
		available.erase(type)
		
		var item = item_scene.instantiate()
		item.item_type = type
		item.bought.connect(func(): get_viewport().gui_release_focus())
		container.add_child(item)
	
	show()
	grab_focus()

func _gui_input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
