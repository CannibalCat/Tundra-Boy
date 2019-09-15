package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
import flixel.system.scaleModes.PixelPerfectScaleMode;

class SplashState extends FlxState 
{
	private var ccLogo:FlxSprite;
	private var presents:FlxSprite;
	private var splashTimer:FlxTimer;


	override public function create():Void
	{
		bgColor = 0xFF000000; 
		FlxG.mouse.visible = false;
		FlxG.scaleMode = new PixelPerfectScaleMode();	
		FlxG.autoPause = false;
		
		ccLogo = new FlxSprite(0, 0, "assets/images/CCLogo.png");
		ccLogo.setPosition(FlxG.width / 2 - ccLogo.width / 2, FlxG.height / 2 - ccLogo.height / 2);
		add(ccLogo); 
		
		FlxG.cameras.fade(0xFF000000, 1, true, onFadeIn);
	}
	
	private function onFadeIn():Void
	{
		splashTimer = new FlxTimer();
		splashTimer.start(1.5, fadeOut, 1);		
	}
	
	private function fadeOut(timer:FlxTimer):Void
	{
		FlxG.cameras.fade(0xFF000000, 1, false, onFinalFade);
	}
	
	private function onFinalFade():Void
	{
		FlxG.switchState(new TitleState()); 
	}

	override public function destroy():Void
	{
		ccLogo = null;
		splashTimer.destroy();
		super.destroy();
	}
}