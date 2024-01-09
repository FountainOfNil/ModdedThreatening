extends Node3D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		body.damage( self)

"""Take note to call 'body.remove(self)' in Player groups if the enemy dies so that the threat notifications disapears!"""
func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		body.remove( self)
