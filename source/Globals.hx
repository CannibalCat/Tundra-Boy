package;

import flixel.FlxState;

class Globals 
{
	public static inline var GAME_VERSION:Float = 1.0;
	public static var currentLevel:Int = 1;
	public static var currentWorld:Int = 1;
	public static var highScores:Array<HighScoreData>;
	public static var playerInitials:Array<String> = [ "A", "A", "A" ];
	public static var playerExtra:Array<String> = [ "", "", "", "", "" ];
	public static var playerBonus:Array<String> = [ "", "", "", "", "" ];
	public static var lastHighScoreEntryNumber:Int = 0;
	public static var pauseGame:Bool = false;
	public static var gameOver:Bool = false;
	public static var globalGameState:PlayState;
	public static var playerScore:Int = 0;
	public static var playerLives:Int = 4;
	public static var playerBonusValue:Int = 5000;
	public static var analogMovementThreshold:Float = 0.2;
	public static var analogStickDelay:Float = 0;
	
	public static function resetWaveVariables():Void
	{
		playerBonusValue = 5000;
	}
	
	public static function resetGameGlobals():Void
	{
		playerScore = 0;
		playerLives = 4;
		playerBonusValue = 5000;
		currentLevel = 1;
		currentWorld = 1;
		gameOver = false;
	}
}