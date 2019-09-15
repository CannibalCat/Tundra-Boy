package;
 
import flixel.FlxG;
import flixel.FlxObject;

class PlayerShot extends Entity
{
    private static var speed:Float = 500;
 
    public function new()
	{
		super();
		loadGraphic("assets/images/PlayerShot.png", false, 16, 16, false);
    }

    override public function update(elapsed:Float):Void
    {
		velocity.x = 0;
		velocity.y = 0; 
		
        if (facing == FlxObject.LEFT)
            velocity.x = -speed;    
		else if (facing == FlxObject.RIGHT)
            velocity.x = speed;    
		else if (facing == FlxObject.UP)
            velocity.y = -speed;    
		else if (facing == FlxObject.DOWN)
            velocity.y = speed;    
			
		// TODO: Need to expire shot after 192 pixel travel distance

		if (x >	FlxG.width || x + width < 0 || y + height < 0 || y > FlxG.height)
			kill();		
			
		super.update(elapsed);
    }
}