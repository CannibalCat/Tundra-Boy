package;

import flixel.FlxG;
import flixel.FlxSprite;

class Flake extends FlxSprite
{
	private var level:Int = 0;
	private var initialized:Bool = false;
	
	public function new(Level:Int = 0) 
	{
		super();
		level = Level;
		loadGraphic("assets/images/SnowFlake.png");
		angularVelocity = FlxG.random.float(-90, 90);	
		revive();
		initialized = true;
	}
	
	override public function revive():Void 
	{
		super.revive();

		if (initialized)
		{
			x = FlxG.random.int(0, FlxG.width);
			y = FlxG.random.int( -5, -10);
		}
		else
		{
			x = FlxG.random.int(0, FlxG.width);
			y = FlxG.random.int( -10, FlxG.height);
		}

		velocity.y = FlxG.random.int(20, 40) * ((level + 1) * .2);
		velocity.x = FlxG.random.int(-25, -50) * ((level + 1) * .1);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (y > FlxG.height)
			revive();
		else if (x + width < 0)
			x = FlxG.width;
		else if (x > FlxG.width)
			x = -16;
		
		super.update(elapsed);
	}
}