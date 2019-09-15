package;

import flixel.FlxSprite;

class IceExplosion extends FlxSprite 
{
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/IceExplosion.png", true, 60, 60, false);	
		animation.add("explode", [0, 1, 2], 12, false);
		animation.play("explode");	
	}
	
	override public function update(elapsed:Float):Void
	{
		if (animation.finished)
			kill();
			
		super.update(elapsed);
	}
}