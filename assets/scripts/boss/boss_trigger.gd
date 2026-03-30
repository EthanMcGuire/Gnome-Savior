extends Area2D

@export var bossDoor: BossDoor;
@export var boss: EvilGnome;
@export var bossMusic : AudioStream;

var bossStarted := false;

func _on_body_entered(body: Node2D) -> void:
	if (bossStarted): return;
	
	if (body is PlayerController):
		bossStarted = true;
		bossDoor.enable();
		GameManager.setCameraLimits(position.x - 16, position.y, position.x - 16 + 480, position.y + 270);
		GameManager.stopMusic();
		%TimerStartDelay.start();

func _on_timer_start_delay_timeout() -> void:
	GameManager.playMusic(bossMusic);
	boss.startBoss();
	
	queue_free();
