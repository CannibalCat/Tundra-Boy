package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import openfl.Assets;

class IntermissionState extends FlxState 
{
	private var largeTextFont:FlxBitmapFont;
	private var waveText:FlxBitmapText;
	private var waveTextShadow:FlxBitmapText;
	private var waveSubText:FlxBitmapText;
	private var waveSubTextShadow:FlxBitmapText;
	private var delayTimer:Float = 2;
	private var bonusRound:Bool = false;
	
	override public function create():Void
	{
		if (Globals.currentLevel % 4 == 0)
			bonusRound = true;
		
		var XMLFontData = Xml.parse(Assets.getText("assets/fonts/LargeTextFont.fnt"));
		largeTextFont = FlxBitmapFont.fromAngelCode("assets/fonts/LargeTextFont_0.png", XMLFontData);
		
		waveTextShadow = new FlxBitmapText(largeTextFont);
		waveTextShadow.letterSpacing = 1;
		if (bonusRound)
			waveTextShadow.text = "BONUS ROUND";
		else
			waveTextShadow.text = "LEVEL " + Globals.currentLevel;
		waveTextShadow.setPosition((FlxG.width / 2 - waveTextShadow.width / 2) + 2, (FlxG.height / 2 - waveTextShadow.height / 2) - 18);
		waveTextShadow.color = 0xFF404040;
		waveTextShadow.visible = false;
		add(waveTextShadow);	
		
		waveText = new FlxBitmapText(largeTextFont);
		waveText.letterSpacing = 1;
		if (bonusRound)
			waveText.text = "BONUS ROUND";
		else
			waveText.text = "LEVEL " + Globals.currentLevel;
		waveText.setPosition(FlxG.width / 2 - waveText.width / 2, (FlxG.height / 2 - waveText.height / 2) - 20);
		waveText.visible = false;
		add(waveText);	
		
		waveSubTextShadow = new FlxBitmapText(largeTextFont);
		waveSubTextShadow.letterSpacing = 1;
		waveSubTextShadow.text = "GET READY!";
		waveSubTextShadow.setPosition((FlxG.width / 2 - waveSubTextShadow.width / 2) + 2, (FlxG.height / 2 - waveSubTextShadow.height / 2) + 22);
		waveSubTextShadow.color = 0xFF404040;
		waveSubTextShadow.visible = false;
		add(waveSubTextShadow);	
		
		waveSubText = new FlxBitmapText(largeTextFont);
		waveSubText.letterSpacing = 1;
		waveSubText.text = "GET READY!";
		waveSubText.setPosition(FlxG.width / 2 - waveSubText.width / 2, (FlxG.height / 2 - waveSubText.height / 2) + 20);
		waveSubText.visible = false;
		add(waveSubText);	
	}
	
	override public function update(elapsed:Float):Void
	{
		ColorCycler.Update(elapsed);
		super.update(elapsed);
		
		if (delayTimer < 2 && delayTimer > 0)
		{
			waveTextShadow.visible = true;
			waveText.visible = true;
		}
		if (delayTimer < 1.5 && delayTimer > 0)
		{
			waveSubTextShadow.visible = true;
			waveSubText.visible = true;
		}
		else if (delayTimer < 0)
		{
			waveTextShadow.kill();
			waveText.kill();
			waveSubTextShadow.kill();
			waveSubText.kill();
			delayTimer = 0;
			FlxG.switchState(new PlayState());
		}
		
		if (delayTimer > 0)
		{
			delayTimer -= elapsed;
			waveText.color = ColorCycler.WilliamsFlash5;
			waveSubText.color = ColorCycler.WilliamsUltraFlash;
		}
	}
	
	override public function destroy():Void
	{
		waveText = null;
		waveTextShadow = null;
		waveSubText = null;
		waveSubTextShadow = null;	
		super.destroy();
	}
}