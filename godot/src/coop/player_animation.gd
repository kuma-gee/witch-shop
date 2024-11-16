class_name PlayerAnimation
extends AnimationTree

const ARMS = "parameters/Arms/blend_amount"
const MOVE = "parameters/Move/blend_amount"
const STATE = "parameters/State/transition_request"

const STATE_CATCH = "catch"
const STATE_MOVE = "move"
const STATE_WORK = "work"

func update(player: Player3D):
	set(MOVE, 1 if player.velocity else 0)
	set(ARMS, 1 if player.hand_3d.is_holding_item() else 0)
	start_move()

func prepare_catch():
	set(STATE, STATE_CATCH)
	
func start_work():
	set(STATE, STATE_WORK)

func start_move():
	set(STATE, STATE_MOVE)
