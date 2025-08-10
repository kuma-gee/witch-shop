class_name Order
extends Control

signal failed()
signal success()

@export var texture: TextureRect
@export var timer: Timer
@export var progress_bar: ProgressBar

var order: PotionItem.Type

func _ready() -> void:
	timer.timeout.connect(func(): failed.emit())
	texture.modulate = PotionItem.get_color(order)

func _process(delta: float) -> void:
	progress_bar.value = progress_bar.max_value * (timer.time_left / timer.wait_time)
