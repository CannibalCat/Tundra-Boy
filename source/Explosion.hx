package;

import flixel.FlxSprite;

class Explosion extends FlxSprite 
{
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/Explosion.png", true, 60, 60, false);	
		animation.add("explode", [0, 1, 2, 3, 4, 5], 10, false);
		animation.play("explode");	
	}
	
	override public function update(elapsed:Float):Void
	{
		if (animation.finished)
			kill();
			
		super.update(elapsed);
	}
}