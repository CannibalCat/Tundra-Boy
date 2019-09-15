package;

import flixel.FlxG;
import flixel.FlxObject;

enum PickupType
{
	FISH;
	POW;
	SILVER_COIN;
	GOLD_COIN;
	SILVER_STAR;
	GOLD_STAR;
	SUPER_STAR;
	EXTRA_LIFE;
}

class Pickup extends Entity 
{
	public var type:PickupType;

	public function new(X:Float=0, Y:Float=0, type:PickupType) 
	{
		super(X, Y);
		
		this.type = type;
		
		if (type == PickupType.FISH)
		{
			loadGraphic("assets/images/Fish.png", true, 32, 32);
			animation.add("default", [0, 1], 12, true);
			animation.play("default");
			scoreValue = 100;
		}
		else if (type == PickupType.POW)
		{
			loadGraphic("assets/images/Pow.png", true, 32, 32);
			animation.add("default", [0, 1, 2, 3, 4, 5, 6], 16, true);
			animation.play("default");
		}
		else if (type == PickupType.SILVER_COIN)
		{
			loadGraphic("assets/images/Coins.png", true, 32, 32);
			animation.add("default", [4, 5, 6, 7], 12, true);
			animation.play("default");
			scoreValue = 500;
		}
		else if (type == PickupType.GOLD_COIN)
		{
			loadGraphic("assets/images/Coins.png", true, 32, 32);
			animation.add("default", [0, 1, 2, 3], 12, true);
			animation.play("default");
			scoreValue = 1000;
		}
		else if (type == PickupType.SILVER_STAR)
		{
			loadGraphic("assets/images/Stars.png", true, 32, 32);
			animation.add("default", [4, 5], 4, true);
			animation.play("default");
			scoreValue = 2000;
		}
		else if (type == PickupType.GOLD_STAR)
		{
			loadGraphic("assets/images/Stars.png", true, 32, 32);
			animation.add("default", [2, 3], 4, true);
			animation.play("default");
			scoreValue = 4000;
		}
		else if (type == PickupType.SUPER_STAR)
		{
			loadGraphic("assets/images/Stars.png", true, 32, 32);
			animation.add("default", [0, 1], 4, true);
			animation.play("default");
			scoreValue = 5000;
		}
		else if (type == PickupType.EXTRA_LIFE)
		{
			loadGraphic("assets/images/ExtraLife.png", true, 32, 32);
			animation.add("default", [0, 7, 1, 7, 2, 7, 3, 7, 4, 7, 5, 7, 6, 7], 12, true);
			animation.play("default");
		}
	}
	
	override public function changeState(newState:Entity.State):Void
	{
		super.changeState(newState);
		
		if (newState == previousState)
			return;
			
		if (newState == Entity.State.PICKED_UP)
		{
			var scoreAnimation:String;
			
			//if (Globals.playerFishCollected > 9)
				//scoreAnimation = "90";
			//else
				//scoreAnimation = Std.string(Globals.playerFishCollected * 10);
			
/*			animation.play(scoreAnimation);
			animation.finishCallback = killPickup;*/
		}
	}
	
	private function killPickup(anim:String):Void
	{
		kill();
   	}
	
	override public function update(elapsed:Float):Void
	{
			
		super.update(elapsed);
	}
}