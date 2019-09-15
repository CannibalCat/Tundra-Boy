package;

import flixel.math.FlxPoint;

class Level 
{
	public var tileMap:TiledLevel;

	public function new() 
	{
		tileMap = new TiledLevel("assets/data/map_" + Globals.currentWorld + "_" + Globals.currentLevel + ".tmx", Globals.globalGameState);		
		
		Globals.globalGameState.add(tileMap.backgroundLayer);
		Globals.globalGameState.add(tileMap.surfaceLayer);
	}
	
	public function loadEntities():Void
	{
		
	}
}