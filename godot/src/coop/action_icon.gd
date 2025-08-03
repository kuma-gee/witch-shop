class_name ActionIcon
extends Sprite3D

@export var chargeable: Chargeable
@export var hide_on_stopped := true

func _ready() -> void:
	material_override = material_override.duplicate()

func set_fill(v: float):
	var mat = material_override as ShaderMaterial
	mat.set_shader_parameter("fill", v)

func _process(delta: float) -> void:
	if not chargeable: return
	
	visible = not hide_on_stopped or chargeable.is_charging
	if chargeable.is_charging:
		set_fill(chargeable.value / chargeable.max_value)
