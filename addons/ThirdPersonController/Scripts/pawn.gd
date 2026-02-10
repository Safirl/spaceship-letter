## Base abstract pawn class. Override it and assign the node to the player controller to use it. 
## Handles default animations and damage function
@abstract
class_name Pawn extends Node3D

func idle():
	pass
func move():
	pass
func fall():
	pass
func jump():
	pass
func edge_grab():
	pass
func wall_slide():
	pass
func hit(damage: float):
	pass
func die():
	pass
