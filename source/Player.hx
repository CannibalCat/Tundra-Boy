package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;

class Player extends Entity 
{
	public static inline var RUN_SPEED:Int = 150;
	private var shootKeys:Array<FlxKey> = [Z, CONTROL];
	private var parentState:PlayState;
	private var playerShootSound:FlxSound;
	
	private var gamepad(get, never):FlxGamepad;
	private function get_gamepad():FlxGamepad 
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		if (gamepad == null)
			gamepad = FlxG.gamepads.getByID(0);
			
		return gamepad;
	}
	
	public function new(X:Float=0, Y:Float=0, parentState:PlayState) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/Player.png", true, 32, 36, false);
		animation.add("idle_right", [9], 1, false);
		animation.add("idle_left", [6], 1, false);
		animation.add("idle_up", [3], 1, false);
		animation.add("idle_down", [0], 1, false);
		animation.add("run_right", [8, 9], 8, true);
		animation.add("run_left", [6, 7], 8, true);
		animation.add("run_up", [4, 5], 8, true);
		animation.add("run_down", [1, 2], 8, true);
		animation.add("fall", [1], 1, false); 
		animation.add("die", [0, 12, 13, 14, 15, 16, 17, 10], 12, false); 
		animation.add("revive", [17, 16, 15, 14, 13, 12, 0], 8, false); 
		
		maxVelocity.set(RUN_SPEED, RUN_SPEED);
		this.parentState = parentState;
		
		//setPosition(FlxG.width / 2 - width / 2, 215);
		
		playerShootSound = FlxG.sound.load("assets/sounds/PlayerShoot.wav");

		facing = FlxObject.DOWN;
		changeState(Entity.State.IDLE);
	}
	
	override public function changeState(newState:Entity.State):Void
	{
		super.changeState(newState);
		
		if (newState == previousState)
			return;
			
		if (newState == Entity.State.DEAD)
		{
			Globals.globalGameState.livesIcon.visible = false;
			animation.play("die");
			animation.finishCallback = killPlayer;
		}
		else if (newState == Entity.State.REVIVE)
		{
			animation.play("revive");
			reset(FlxG.width / 2 - width / 2, 315);
			animation.finishCallback = restartPlayer;
		}
		else if (newState == Entity.State.IDLE)
		{
			velocity.x = 0;
			velocity.y = 0;
			
			if (facing == FlxObject.UP)
				animation.play("idle_up");
			else if (facing == FlxObject.DOWN)
				animation.play("idle_down");
			else if (facing == FlxObject.LEFT)
				animation.play("idle_left");
			else if (facing == FlxObject.RIGHT)
				animation.play("idle_right");
		}
	}
	
	public override function destroy():Void
	{
		playerShootSound.destroy();
		super.destroy();
	}
	
	public override function update(elapsed:Float):Void
	{
		velocity.x = 0;
		velocity.y = 0;		

		if (Globals.pauseGame)
			return;
			
 		if (currentState != Entity.State.DEAD)
		{
			var gamepad = get_gamepad();
			
			// Player shoot projectile
			if ((FlxG.keys.anyJustPressed(shootKeys) || gamepad.anyJustPressed([FlxGamepadInputID.B])))
			{
				if (facing == FlxObject.LEFT)
					shootLeft();
				else if (facing == FlxObject.RIGHT)
					shootRight();
				else if (facing == FlxObject.UP)
					shootUp();
				else if (facing == FlxObject.DOWN)
					shootDown();
			}
			
			if ((FlxG.keys.anyPressed([LEFT, A]) || gamepad.analog.value.LEFT_STICK_X < 0 || gamepad.pressed.DPAD_LEFT))
			{
				velocity.x = -RUN_SPEED;
				velocity.y = 0;
				changeState(Entity.State.MOVING);
				facing = FlxObject.LEFT;
			}
			
			if ((FlxG.keys.anyPressed([RIGHT, D]) || gamepad.analog.value.LEFT_STICK_X > 0 || gamepad.pressed.DPAD_RIGHT))
			{
				velocity.x = RUN_SPEED;
				velocity.y = 0;
				changeState(Entity.State.MOVING);
				facing = FlxObject.RIGHT;
			}
			
			if ((FlxG.keys.anyPressed([UP, W]) || gamepad.analog.value.LEFT_STICK_Y < 0 || gamepad.pressed.DPAD_UP))
			{
				velocity.x = 0;
				velocity.y = -RUN_SPEED;
				changeState(Entity.State.MOVING);
				facing = FlxObject.UP;
			}
			
			if ((FlxG.keys.anyPressed([DOWN, S]) || gamepad.analog.value.LEFT_STICK_Y > 0 || gamepad.pressed.DPAD_DOWN))
			{
				velocity.x = 0;
				velocity.y = RUN_SPEED;
				changeState(Entity.State.MOVING);
				facing = FlxObject.DOWN;
			}
			
			if (velocity.x > 0)
				animation.play("run_right");
			else if (velocity.x < 0) 
				animation.play("run_left");
			else if (velocity.y < 0)
				animation.play("run_up");
			else if (velocity.y > 0)
				animation.play("run_down");				
			else if (velocity.x == 0 && velocity.y == 0)
			{
				if (facing == FlxObject.UP)
					animation.play("idle_up");
				else if (facing == FlxObject.DOWN)
					animation.play("idle_down");
				else if (facing == FlxObject.LEFT)
					animation.play("idle_left");
				else if (facing == FlxObject.RIGHT)
					animation.play("idle_right");				
			}
			
			// Sync player position to tile grid here
		}
		
		super.update(elapsed);
	}
	
    private function shootRight():Void
	{
		var bullet = Globals.globalGameState.playerProjectiles.recycle();
		bullet.x = x + width + 2;
		bullet.y = (y + (height / 2)) - (bullet.height / 2);
		bullet.facing = FlxObject.RIGHT;
		playerShootSound.play(true);
    }
	
	private function shootLeft():Void
	{
		var bullet = Globals.globalGameState.playerProjectiles.recycle();
		bullet.x = x - bullet.width - 2;
		bullet.y = (y + (height / 2)) - (bullet.height / 2);
		bullet.facing = FlxObject.LEFT;
		playerShootSound.play(true);
    }
	
	private function shootUp():Void
	{
		var bullet = Globals.globalGameState.playerProjectiles.recycle();
		bullet.x = (x + (width / 2)) - (bullet.width / 2);
		bullet.y = y - bullet.height - 2;
		bullet.facing = FlxObject.UP;
		playerShootSound.play(true);
    }
	
	private function shootDown():Void
	{
		var bullet = Globals.globalGameState.playerProjectiles.recycle();
		bullet.x = (x + (width / 2)) - (bullet.width / 2);
		bullet.y = y + height + 2;
		bullet.facing = FlxObject.DOWN;
		playerShootSound.play(true);
    }
	
	private function killPlayer(anim:String):Void
	{
		kill();
		animation.finishCallback = null;
		
		Globals.playerLives--;	
		if (Globals.playerLives == 0)
			Globals.gameOver = true;
		else
			changeState(Entity.State.REVIVE);
	}
	
	private function restartPlayer(anim:String):Void
	{
		animation.finishCallback = null;
		changeState(Entity.State.IDLE);	
	}
}