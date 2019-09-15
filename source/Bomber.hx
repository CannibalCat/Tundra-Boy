package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.system.FlxSound;

class Bomber extends Entity 
{
	private var maxSpeed:Float;
	private var maxFPS:Int;
	private var idleTime:Float = 0;
	private var idleTimeElapsed:Float = 0;
	private var explosionSound:FlxSound;
	
	public function new(X:Float=0, Y:Float=0, speed:Entity.Speed, ?idleTime:Float) 
	{
		super(X, Y);
		
		target = Globals.globalGameState.player;
		
		if (idleTime != null)
			this.idleTime = idleTime;
		
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
		
		loadGraphic("assets/images/Bomber.png", true, 32, 32, false);
		
		animation.add("moving", [0, 1, 2, 1, 3, 4, 3], 32, true);
		animation.add("warning", [5, 6, 7], 32, true);
		
		explosionSound = FlxG.sound.load("assets/sounds/Explosion1.wav");
		
		setFacingFlip(FlxObject.LEFT, false, false); 
		setFacingFlip(FlxObject.RIGHT, true, false); 
		
		changeState(Entity.State.IDLE);
	}
	
	override public function changeState(newState:Entity.State):Void
	{
		super.changeState(newState);
		
		if (newState == previousState)
			return;
			
		if (newState == Entity.State.MOVING)
		{
			if (facing == FlxObject.RIGHT)
				animation.play("moving");
			else if (facing == FlxObject.LEFT)
				animation.play("moving");
			else if (facing == FlxObject.UP)
				animation.play("moving");
			else if (facing == FlxObject.DOWN)
				animation.play("moving");
		}
		else if (newState == Entity.State.IDLE) 
		{
			velocity.x = 0;
			velocity.y = 0;
			animation.play("idle");
		}
		else if (newState == Entity.State.EXPLODING) 
		{
			velocity.x = 0;
			velocity.y = 0;
			immovable = true;
			animation.play("warning");
			//fuseSound.play();
			animation.finishCallback = explode;
		}
	}
	
	public function explode(anim:String):Void
	{
		var explosion:Explosion = new Explosion(x + origin.x - 30, y + origin.y - 30);
		Globals.globalGameState.explosions.add(explosion);
		explosionSound.play();
		FlxG.camera.flash(0xFFFFFFFF, 0.1);
		FlxG.camera.shake(0.02, 0.75);
		kill();
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
		
		if (currentState != Entity.State.EXPLODING)
		{
			if (FlxMath.distanceBetween(this, target) < 50) 
				changeState(Entity.State.EXPLODING);
		}
		
		Globals.globalGameState.level.tileMap.collideWithLevel(this);
	}
	
	override public function changeRandomDirection(?excludedDir:Int):Void
	{
		super.changeRandomDirection(excludedDir);

		if (facing == FlxObject.RIGHT)
			animation.play("moving");
		else if (facing == FlxObject.LEFT)
			animation.play("moving");
		else if (facing == FlxObject.UP)
			animation.play("moving");
		else if (facing == FlxObject.DOWN)
			animation.play("moving");		
	}
}