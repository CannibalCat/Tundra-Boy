package;

import flixel.FlxObject;

class SnowBall extends Entity 
{
	private var maxSpeed:Float;
	private var maxFPS:Int;
	
	public function new(X:Float=0, Y:Float=0, speed:Entity.Speed) 
	{
		super(X, Y);
		
		if (speed == Entity.Speed.SLOW)	
		{
			maxSpeed = 100;
			maxFPS = 12;
		}
		else if (speed == Entity.Speed.MEDIUM)
		{
			maxSpeed = 150;
			maxFPS = 24;
		}
		else if (speed == Entity.Speed.FAST)
		{
			maxSpeed = 200;
			maxFPS = 32;
		}
		else if (speed == Entity.Speed.ULTRA)
		{
			maxSpeed = 250;
			maxFPS = 64;
		}
		
		loadGraphic("assets/images/Snowball.png", true, 32, 32);
		
		animation.add("falling", [4], 1, false);
		animation.add("rolling", [4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 1, 2, 3], 32, true);
		
		immovable = true;
		
		changeState(Entity.State.MOVING);
	}
	
 	override public function changeState(newState:Entity.State):Void
	{
		if (newState == Entity.State.MOVING)
			animation.play("rolling");
		else if (newState == Entity.State.FALLING)
		{
			animation.play("falling");
		}
		else if (newState == Entity.State.IDLE) 
		{
			velocity.x = 0;
			velocity.y = 0;
		}
	
		super.changeState(newState);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (currentState == Entity.State.MOVING)
		{
			velocity.y = maxSpeed;
			velocity.x = 0;
		}	
	
		super.update(elapsed);
		
		if (Globals.globalGameState.level.tileMap.collideWithLevel(this))
			kill();
	}
}