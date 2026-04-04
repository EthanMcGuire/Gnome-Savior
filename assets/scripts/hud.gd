extends Control
class_name HUD

var hudHeart := preload("res://assets/scenes/UI/hud_heart.tscn");

func updateLives(lives: int):
	%LivesLabel.text = str(lives);

func updateCoins(coins: int):
	%CoinLabel.text = str(coins);

func updateDeaths(deaths: int):
	%DeathLabel.text = str(deaths);

func updateMaxHealth(health: int):
	var currentHealthCount;
	
	currentHealthCount = %Health.get_child_count();
	
	if (currentHealthCount < health):
		while currentHealthCount < health:
			_addHeart();
			currentHealthCount += 1;
	elif (currentHealthCount > health):
		while currentHealthCount > health:
			_removeLastHeart();
			currentHealthCount -= 1;

func updateHealth(health: int):
	var current := 1;
	
	for heart in %Health.get_children():
		if (health >= current):
			heart.setFull();
		else:
			heart.setEmpty();
		
		current += 1;

func _addHeart() -> void:
	var heart: HudHeart;
			
	heart = preload("res://assets/scenes/UI/hud_heart.tscn").instantiate();
	heart.setEmpty();
	heart.position.x = %Health.get_child_count() * 16.0;
	
	%Health.add_child(heart);

func _removeLastHeart() -> void:
	var heartToRemove;
			
	heartToRemove = %Health.get_children()[%Health.get_child_count() - 1];
	heartToRemove.queue_free();
	%Health.remove_child(heartToRemove);
