extends Trap
class_name PlayerEvil

const FOLLOW_DElAY := 0.5;
const START_LEFT_OFFSET := Vector2(32.0, 0);
const MOVE_SPEED := 136.0;

var delay := FOLLOW_DElAY;
var playerSpawn: Vector2;
var playerMoved := false;
var following := false;
var started := false;
var didPlayerJump := false;
var killedPlayer := false;

var playerPositions := [];
var playerAnimations := [];
var playerSpriteFlip := [];
var playerJumps := [];
var playerDelta := [];
var currentPositionDelta := 0.0;
var currentChaseDelta := 0.0;

func _ready() -> void:
	super();
	visible = false;
	modulate = Color(1, 1, 1, 0.5);

func playerJumped() -> void:
	didPlayerJump = true;

func _process(delta: float) -> void:
	if (!started || killedPlayer): return;
	
	if (playerMoved): _updatePlayerPositions(delta);
	
	if (!following):
		# Wait until the player moves before we start our delay
		if (!playerMoved):
			if (playerSpawn != GameManager.getPlayerPosition()):
				playerMoved = true;
		else:
			delay -= delta;
			
			if (delay <= 0):
				_startFollowing();
	else:
		_chase(delta);
		
		var bodies = %Area2D.get_overlapping_bodies();
		
		for body in bodies:
			_dealDamage(body, global_position);
			
		if (GameManager.getPlayerDead()):
			killedPlayer = true;
			%PlayerAnimator.play_animation("laugh");

func _updatePlayerPositions(delta: float) -> void:
	currentPositionDelta += delta;
	
	playerPositions.append(GameManager.getPlayerPosition());
	playerAnimations.append(GameManager.getPlayerAnimation());
	playerSpriteFlip.append(GameManager.getPlayerHFlip());
	playerJumps.append(didPlayerJump);
	playerDelta.append(currentPositionDelta);
	
	didPlayerJump = false;

func _prefillChaseArrays() -> void:
	var playerPosition: Vector2;
	var goalX: float;
	var delta := 0.01;
	
	playerSpawn = GameManager.getPlayerPosition();
	playerPosition = playerSpawn - START_LEFT_OFFSET;
	goalX = playerSpawn.x;
	currentPositionDelta = 0.0;
	
	playerPositions.append(playerPosition);
	playerAnimations.append("idle");
	playerSpriteFlip.append(false);
	playerJumps.append(false);
	playerDelta.append(currentPositionDelta);
	
	while playerPosition.x < goalX:
		playerPosition.x += MOVE_SPEED * delta;
		currentPositionDelta += delta;
		playerPositions.append(playerPosition);
		playerAnimations.append("walk");
		playerSpriteFlip.append(false);
		playerJumps.append(false);
		playerDelta.append(currentPositionDelta);

func _chase(delta: float) -> void:
	currentChaseDelta += delta;
	
	if (currentChaseDelta >= playerDelta[0]):
		position = playerPositions[0];
		%PlayerAnimator.play_animation(playerAnimations[0]);
		%PlayerAnimator.set_sprite_h_flip(playerSpriteFlip[0]);
		
		if (playerJumps[0]):
			%AudioStreamJump.play(0.0);
		
		playerPositions.remove_at(0);
		playerAnimations.remove_at(0);
		playerSpriteFlip.remove_at(0);
		playerJumps.remove_at(0);
		playerDelta.remove_at(0);

func _startFollowing() -> void:
	following = true;
	visible = true;
	modulate = Color(1, 1, 1, 0.9);

func _on_start_delay_timeout() -> void:
	started = true;
	visible = true;
	
	_prefillChaseArrays();
	
	position = playerPositions[0];
	%PlayerAnimator.play_animation(playerAnimations[0]);
	%PlayerAnimator.set_sprite_h_flip(playerSpriteFlip[0]);
