class_name PlayerAnimation
extends AnimationTree

const ARMS = "parameters/Arms/blend_amount"
const HOLD = "parameters/Hold/blend_amount"
const MOVE = "parameters/Move/blend_amount"

func update(player: Player3D):
	set(MOVE, 1 if player.velocity else 0)
	set(ARMS, 1 if player.hand_3d.is_holding_item() or player.is_hold_pressed else 0)
	set(HOLD, 1 if player.hand_3d.is_holding_item() else 0)
