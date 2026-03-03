extends Node2D
class_name SceneDeathTransition;

const SHOW_LIVES_DELAY := 1.0;
const LIVES_REDUCE_DELAY := 1.0;
const END_TRANSITION_DELAY := 1.0;

var nextScene: PackedScene;
var transitionStarted := false;
var gameOver = false;

func startTransition(transitionTime: float, _nextScene: PackedScene) -> void:
	var tween;
	var color: Color = Color(0.0, 0.0, 0.0, 1.0);
	
	if (transitionStarted): return;
	
	transitionStarted = true;
	get_tree().paused = true;
	
	tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(%ColorRect, "color", color, transitionTime);
	tween.tween_callback(showLives).set_delay(SHOW_LIVES_DELAY);
	tween.tween_callback(reduceLives).set_delay(LIVES_REDUCE_DELAY);
	tween.tween_callback(endTranstition).set_delay(END_TRANSITION_DELAY);
	
	nextScene = _nextScene;

func showLives() -> void:
	%Lives.visible = true;
	%LivesLabel.text = str(GameManager.getLives());
	
func reduceLives() -> void:
	if (GameManager.getLives() > 0):
		GameManager.addLives(-1);
		GameManager.setPlayerHp(GameManager.getPlayerMaxHp());
		%LivesLabel.text = str(GameManager.getLives());
		%AudioStreamHaha.play();
	else:
		%LivesLabel.text = "GAME OVER FUCKER";
		gameOver = true;
		%AudioStreamGameOver.play();

func endTranstition() -> void:
	if (gameOver):
		GameManager.gameOver();
		
	queue_free();
	get_tree().paused = false;
	GameManager.loadLevel(nextScene);
