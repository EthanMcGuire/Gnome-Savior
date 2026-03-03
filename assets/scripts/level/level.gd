extends Node2D
class_name Level

@export var levelName: String = "Test Level";
@export var levelWidth := 1600.0;
@export var levelHeight := 1600.0;
@export var music: AudioStream;

func addGnome(gnomeNode) -> void:
	%Gnomes.add_child(gnomeNode);
