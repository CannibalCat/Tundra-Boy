package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.system.FlxSound;
import openfl.Assets;

class TitleState extends FlxState 
{
	private var titleLogo:FlxSprite;
	private var titlePresentsShadow:FlxSprite;
	private var titlePresents:FlxSprite;
	private var programmedText:FlxSprite;
	private var musicText:FlxSprite;
	private var startText:FlxSprite;
	private var startTextShadow:FlxSprite;
	private var background:FlxSprite;
	private var snowFlakes:FlxTypedGroup<Flake>;

	private var gamepad(get, never):FlxGamepad;
	private function get_gamepad():FlxGamepad 
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		if (gamepad == null)
			gamepad = FlxG.gamepads.getByID(0);
			
		return gamepad;
	}
	
	override public function create():Void
	{
		bgColor = 0xFF000000; 
		
		background = new FlxSprite(0, 0, "assets/images/TitleBackground.png");
		add(background);
		
		snowFlakes = new FlxTypedGroup<Flake>();
		add(snowFlakes);
		
		for (i in 0...150)
		{
			snowFlakes.add(new Flake(i % 10));
		}
		
		titlePresentsShadow = new FlxSprite(0, 0, "assets/images/Presents.png");
		titlePresentsShadow.setPosition((FlxG.width / 2 - titlePresentsShadow.width / 2) + 2, 22);
		titlePresentsShadow.color = 0xFF000000;
		titlePresentsShadow.immovable = true;
		add(titlePresentsShadow);
		
		titlePresents = new FlxSprite(0, 0, "assets/images/Presents.png");
		titlePresents.setPosition(FlxG.width / 2 - titlePresents.width / 2, 20);
		titlePresents.immovable = true;
		add(titlePresents);
		
		titleLogo = new FlxSprite(0, 0, "assets/images/TitleLogo.png");
		titleLogo.setPosition(FlxG.width / 2 - titleLogo.width / 2, 65);
		titleLogo.immovable = true;
		add(titleLogo);

		programmedText = new FlxSprite(0, 0, "assets/images/Programmed.png");
		programmedText.setPosition(FlxG.width / 2 - programmedText.width / 2, 275);
		programmedText.immovable = true;
		add(programmedText);	
		
		//musicText = new FlxSprite(0, 0, "assets/images/Music.png");
		//musicText.setPosition(FlxG.width / 2 - musicText.width / 2, 300);
		//musicText.immovable = true;
		//bitmapText.add(musicText);	
		
		startTextShadow = new FlxSprite(0, 0, "assets/images/StartShadow.png");
		startTextShadow.setPosition((FlxG.width / 2 - startTextShadow.width / 2) + 2, 352);
		startTextShadow.immovable = true;
		add(startTextShadow);	
		
		startText = new FlxSprite(0, 0, "assets/images/Start.png");
		startText.setPosition(FlxG.width / 2 - startText.width / 2, 350);
		startText.immovable = true;
		add(startText);	
	}
	
	override public function update(elapsed:Float):Void
	{
		ColorCycler.Update(elapsed);
		
		startText.color = ColorCycler.WilliamsUltraFlash;

		if (FlxG.keys.justPressed.SPACE || gamepad.justPressed.START)
		{
			Globals.resetGameGlobals(); 
			FlxG.switchState(new IntermissionState());
		}
		
		super.update(elapsed);
	}
	
	override public function destroy():Void
	{
		titleLogo = null;
		titlePresentsShadow = null;
		titlePresents = null;
		programmedText = null;
		musicText = null;
		startText = null;
		startTextShadow = null;
		background = null;
		super.destroy();
	}
}