package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

enum Speed
{
	SLOW;
	MEDIUM;
	FAST;
	ULTRA;
}

enum State
{
	IDLE;
	MOVING;
	JUMPING;
	FROZEN;
	THAWING;
	FALLING;
	EXPLODING;
	PICKED_UP;
	REVIVE;
	DEAD;
}

class Entity extends FlxSprite
{
	public var currentState:State;
	public var previousState:State;
	public var followTarget:Bool = false;
	public var target:Entity;
	public var scoreValue:Int = 0;
	public var offset_x:Float;
	public var offset_y:Float;

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		currentState = IDLE;
		previousState = IDLE;
		offset_x = 0;
		offset_y = 0;
		super(X, Y);
	}
	
	public function changeState(newState:Entity.State):Void
	{
		previousState = currentState;
		currentState = newState;
	}
	
	public function changeDirection(newDirection:Int):Void
	{
		facing = newDirection;
	}
	
	public function changeRandomDirection(?excludedDir:Int):Void
	{
		var newDirection:Int;
		
		if (excludedDir != null)
		{
			var exclude:Array<Int> = [excludedDir];
			newDirection = FlxG.random.int(1, 4, exclude);
		}
		else
			newDirection = FlxG.random.int(1, 4);
	
		if (newDirection == 1)
			facing = FlxObject.UP;
		else if (newDirection == 2)
			facing = FlxObject.DOWN;
		else if (newDirection == 3)
			facing = FlxObject.LEFT;
		else if (newDirection == 4)
			facing = FlxObject.RIGHT;
	}
}