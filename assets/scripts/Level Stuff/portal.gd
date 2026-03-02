extends Area2D

@export var linkedPortal: PortalEndpoint = null;

func _on_body_entered(body: Node2D) -> void:
	if (body is PlayerController):
		_usePortal();
		
func _usePortal() -> void:
	if (!linkedPortal):
		print("Linked portal not set!!!");
		return;
	
	linkedPortal.warpPlayer();
