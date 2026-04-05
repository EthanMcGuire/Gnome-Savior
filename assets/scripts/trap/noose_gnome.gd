extends Trap

const TRAVEL_DISTANCE := 240.0;
const START_SPEED := 128.0;
const SPEED_INCREASE := 350.0;
const RAISE_SPEED := 160.0;
const RAISE_DELAY := 0.5;

var distanceToTravel = TRAVEL_DISTANCE;
var currentSpeed = START_SPEED;
var falling = true;
var currentRaiseDelay := RAISE_DELAY;

func _ready() -> void:
	super();
	
	if (randf() <= 0.5):
		%Sprites.scale.x = -1.0;

func _physics_process(delta: float) -> void:
	if (falling):
		currentSpeed += SPEED_INCREASE * delta;
			
		var moveAmount = min(currentSpeed * delta, distanceToTravel);
		
		distanceToTravel -= moveAmount;
		global_position.y += moveAmount;
		
		if (distanceToTravel <= 0.0):
			falling = false;
			distanceToTravel = TRAVEL_DISTANCE;
	else:
		currentRaiseDelay = max(currentRaiseDelay - delta, 0.0);
		
		if (currentRaiseDelay == 0.0):
			global_position.y -= RAISE_SPEED * delta;
			distanceToTravel -= RAISE_SPEED * delta;
			
			if (distanceToTravel <= 0.0):
				queue_free();

func _on_area_2d_body_entered(body: Node2D) -> void:
	_dealDamage(body, global_position);
