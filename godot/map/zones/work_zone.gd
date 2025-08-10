class_name WorkZone
extends Zone

@export var work_stations: Array[PrepArea3D] = []

func has_all_processes(list: Array) -> bool:
	for item in list:
		if find_process(item) == null:
			return false
	return not list.is_empty()

func find_process(type: PotionItem.Process) -> PrepArea3D:
	for node in work_stations:
		if is_instance_valid(node) and node.type == type:
			return node
	return null

func set_processes(list: Array):
	for i in work_stations.size():
		var node = work_stations[i]
		if not is_instance_valid(node): continue
		
		var item = list[i] if i < list.size() else null

		if item != null:
			node.type = item
		else:
			node.queue_free()
		
	
	
