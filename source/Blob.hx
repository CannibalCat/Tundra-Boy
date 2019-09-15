package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class Blob extends Entity 
{
	private var maxSpeed:Float;
	private var maxFPS:Int;
	private var idleTime:Float = 0;
	private var thawTimer:Float = 0;
	private var idleTimeElapsed:Float = 0;
	private var shakeOffset:Int = 0;
	private var shakeOrigin:Float;
	private var iceBreakSound:FlxSound;
	
	public function new(X:Float=0, Y:Float=0, color:FlxColor, speed:Entity.Speed, facing:Int) 
	{
		super(X, Y);
		
		scoreValue = 250;
		this.facing = facing;
		
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
		
		loadGraphic("assets/images/Blob.png", true, 32, 32);
		
		if (color == FlxColor.GREEN)
		{
			animation.add("move_right", [0, 1, 2, 1], maxFPS, true);
			animation.add("move_left", [3, 4, 5, 4], maxFPS, true);
			animation.add("move_up", [6, 7, 8, 7], maxFPS, true);
			animation.add("move_down", [9, 10, 11, 10], maxFPS, true);
		}
		else if (color == FlxColor.BLUE)
		{
			animation.add("move_right", [12, 13, 14, 13], maxFPS, true);
			animation.add("move_left", [15, 16, 17, 16], maxFPS, true);
			animation.add("move_up", [18, 19, 20, 19], maxFPS, true);
			animation.add("move_down", [21, 22, 23, 22], maxFPS, true);
		}
		else if (color == FlxColor.ORANGE)
		{
			animation.add("move_right", [24, 25, 26, 25], maxFPS, true);
			animation.add("move_left", [27, 28, 29, 28], maxFPS, true);
			animation.add("move_up", [30, 31, 32, 31], maxFPS, true);
			animation.add("move_down", [33, 34, 35, 34], maxFPS, true);
		}
		else if (color == FlxColor.RED)
		{
			animation.add("move_right", [36, 37, 38, 37], maxFPS, true);
			animation.add("move_left", [39, 40, 41, 40], maxFPS, true);
			animation.add("move_up", [42, 43, 44, 43], maxFPS, true);
			animation.add("move_down", [45, 46, 47, 46], maxFPS, true);
		}
		
		iceBreakSound = FlxG.sound.load("assets/sounds/IceBreak.wav");
		
		changeState(Entity.State.IDLE);
	}
	
 	override public function changeState(newState:Entity.State):Void
	{
		if (newState == Entity.State.MOVING)
		{
			if (facing == FlxObject.RIGHT)
				animation.play("move_right");
			else if (facing == FlxObject.LEFT)
				animation.play("move_left");
			else if (facing == FlxObject.UP)
				animation.play("move_up");
			else if (facing == FlxObject.DOWN)
				animation.play("move_down");
		}
		else if (newState == Entity.State.IDLE) 
		{
			velocity.x = 0;
			velocity.y = 0;
		}
		else if (newState == Entity.State.FROZEN)
		{
			velocity.x = 0;
			velocity.y = 0;
			shakeOrigin = x;
			animation.play("frozen");	
		}
		else if (newState == Entity.State.THAWING)
		{
			animation.play("thawing");
		}
	
		super.changeState(newState);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (currentState == Entity.State.MOVING)
		{		
			if (justTouched(FlxObject.RIGHT)) 
				changeRandomDirection(FlxObject.RIGHT);
			else if (justTouched(FlxObject.LEFT)) 
				changeRandomDirection(FlxObject.LEFT);
			else if (justTouched(FlxObject.UP)) 
				changeRandomDirection(FlxObject.UP);
			else if (justTouched(FlxObject.DOWN)) 
				changeRandomDirection(FlxObject.DOWN);
		}
		
		super.update(elapsed);		
		
		if (currentState == Entity.State.MOVING)
		{
			if (facing == FlxObject.RIGHT)
			{
				velocity.y = 0;
				velocity.x = maxSpeed;
			}
			else if (facing == FlxObject.LEFT)
			{
				velocity.y = 0;
				velocity.x = -maxSpeed;
			}
			else if (facing == FlxObject.UP)
			{
				velocity.y = -maxSpeed;
				velocity.x = 0;
			}
			else if (facing == FlxObject.DOWN)
			{
				velocity.y = maxSpeed;
				velocity.x = 0;
			}
		}	
		else if (currentState == Entity.State.IDLE)
		{
			if (idleTimeElapsed >= idleTime)
				changeState(Entity.State.MOVING);
			else
				idleTimeElapsed += elapsed;
		}
		else if (currentState == Entity.State.FROZEN)
		{
			shakeOffset = FlxG.random.int(-1, 1);
			x = shakeOrigin + shakeOffset;
			thawTimer += elapsed;
			if (thawTimer > 2)
			{
				thawTimer = 0;
				changeState(Entity.State.THAWING);
			}
		}
		else if (currentState == Entity.State.THAWING)
		{
			shakeOffset = FlxG.random.int(-2, 2);
			x = shakeOrigin + shakeOffset;
			if (animation.finished)
			{
				Globals.globalGameState.explosions.add(new IceExplosion(x + origin.x - 30, y + origin.y - 30));
				iceBreakSound.play();
				
				maxSpeed += 25;
				if (maxSpeed > 450)
					maxSpeed = 450;
					
				changeState(Entity.State.MOVING);
			}
		}
		
		Globals.globalGameState.level.tileMap.collideWithLevel(this);
	}
	
	override public function changeRandomDirection(?excludedDir:Int):Void
	{
		super.changeRandomDirection(excludedDir);

		if (facing == FlxObject.RIGHT)
			animation.play("move_right");
		else if (facing == FlxObject.LEFT)
			animation.play("move_left");
		else if (facing == FlxObject.UP)
			animation.play("move_up");
		else if (facing == FlxObject.DOWN)
			animation.play("move_down");		
	}
}