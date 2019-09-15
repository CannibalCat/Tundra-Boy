package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var PATH_LEVEL_TILESHEETS = "assets/images/";
	
	// Array of tilemaps used for collision
	public var surfaceLayer:FlxGroup;
	public var objectsLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	public var collisionMarkers:FlxGroup;
	private var collidableTileLayers:Array<FlxTilemap>;
	
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	
	public function new(tiledLevel:Dynamic, state:PlayState)
	{
		super(tiledLevel);
		
		imagesLayer = new FlxGroup();
		surfaceLayer = new FlxGroup();
		objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		loadImages();
		loadObjects(state);
		
		// Load Tile Maps
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) 
				continue;
				
			var tileLayer:TiledTileLayer = cast layer;
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath = new Path(tileSet.imageSource);
			var processedPath = PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			//tilemap.useScaleHack = true;
			
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);
			
			if (tileLayer.properties.contains("animated"))
			{
				var tileset = tilesets["Tiles"];
				var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
				for (tileProp in tileset.tileProps)
				{
					if (tileProp != null && tileProp.animationFrames.length > 0)
					{
						specialTiles[tileProp.tileID + tileset.firstGID] = tileProp;
					}
				}
				
				var tileLayer:TiledTileLayer = cast layer;
				tilemap.setSpecialTiles([
					for (tile in tileLayer.tiles)
						if (tile != null && specialTiles.exists(tile.tileID))
							getAnimatedTile(specialTiles[tile.tileID], tileset)
						else null
				]);
			}
			
			// NOTE: add 'scrollfactor" as a custom property to tile layer(s) for parallax scrolling, etc.
			if (tileLayer.properties.contains("scrollfactor"))
			{
				var scrollFactor:Float = Std.parseFloat(tileLayer.properties.get("scrollfactor"));
				tilemap.scrollFactor.set(scrollFactor, scrollFactor);
			}

			if (tileLayer.properties.contains("nocollide"))
			{
				surfaceLayer.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				
				backgroundLayer.add(tilemap);
				collidableTileLayers.push(tilemap);
			}
		}
	}

	private function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial
	{
		var special = new FlxTileSpecial(1, false, false, 0);
		var n:Int = props.animationFrames.length;
		var offset = 0;
		special.addAnimation(
			[for (i in 0 ... n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID],
			(1000 / props.animationFrames[0].duration)
		);
		return special;
	}
	
	public function loadObjects(state:PlayState)
	{
		var layer:TiledObjectLayer;
		
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
				
			var objectLayer:TiledObjectLayer = cast layer;

			//collection of images layer
			if (layer.name == "images")
			{
				for (o in objectLayer.objects)
				{
					loadImageObject(o);
				}
			}
			
			//objects layer
			if (layer.name == "Objects")
			{
				for (o in objectLayer.objects)
				{
					loadObject(state, o, objectLayer, objectsLayer);
				}
			}
		}
	}
	
	private function loadImageObject(object:TiledObject)
	{
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);
		
		// Background layer sprites
		var levelsDir:String = "assets/images/";
		
		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}
		
		//Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat( object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth,depth);
		}

		backgroundLayer.add(decoSprite);
	}
	
	private function loadObject(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
		
		switch (o.type.toLowerCase())
		{
			case "player_start":
				state.player.setPosition(x, y);
				
			//case "spring":
				//var trap:ChainTrap = new ChainTrap(x, y);
				//trap.solid = true;
				//trap.immovable = true;
				//state.traps.add(trap);						
				
			case "enemy":
				switch (o.name.toLowerCase())
				{
					case "blue_blob":
						var blob:Blob = new Blob(x, y, FlxColor.BLUE, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(blob);
						
					case "orange_blob":
						var blob:Blob = new Blob(x, y, FlxColor.ORANGE, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(blob);
						
					case "green_blob":
						var blob:Blob = new Blob(x, y, FlxColor.GREEN, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(blob);
						
					case "red_blob":
						var blob:Blob = new Blob(x, y, FlxColor.RED, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(blob);
						
					case "snowball":
						var snowball:SnowBall = new SnowBall(x, y, Entity.Speed.SLOW);
						state.enemies.add(snowball);
						
					case "gray_egghead":
						var egghead:Egghead = new Egghead(x, y, FlxColor.GRAY, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(egghead);
						
					case "yellow_egghead":
						var egghead:Egghead = new Egghead(x, y, FlxColor.YELLOW, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(egghead);
						
					case "blue_eegghead":
						var egghead:Egghead = new Egghead(x, y, FlxColor.BLUE, Entity.Speed.SLOW, FlxObject.DOWN);
						state.enemies.add(egghead);
						
					case "bomber":
						var bomber:Bomber = new Bomber(x, y, Entity.Speed.SLOW, FlxObject.LEFT);
						state.enemies.add(bomber);
						
					case "fireball":
						var fireball:Fireball = new Fireball(x, y, Entity.Speed.SLOW, FlxObject.LEFT);
						state.enemies.add(fireball);
						
					case "piranha":
						var piranha:Piranha = new Piranha(x, y, FlxObject.LEFT);
						state.enemies.add(piranha);
					
						
				}
				
			case "pickup":
				var pickup:Pickup = null;
				switch (o.name.toLowerCase())
				{
					case "pow":
						pickup = new Pickup(x, y, Pickup.PickupType.POW);
						
					case "fish":
						pickup = new Pickup(x, y, Pickup.PickupType.FISH);
						
					case "silver_coin":
						pickup = new Pickup(x, y, Pickup.PickupType.SILVER_COIN);
						
					case "gold_coin":
						pickup = new Pickup(x, y, Pickup.PickupType.GOLD_COIN);
						
					case "silver_star":
						pickup = new Pickup(x, y, Pickup.PickupType.SILVER_STAR);
						
					case "gold_star":
						pickup = new Pickup(x, y, Pickup.PickupType.GOLD_STAR);
						
					case "super_star":
						pickup = new Pickup(x, y, Pickup.PickupType.SUPER_STAR);
						
					case "extra_life":
						pickup = new Pickup(x, y, Pickup.PickupType.EXTRA_LIFE);						
				}
				state.pickups.add(pickup);
				
			case "collision_marker":
				var marker = new FlxObject(x, y, o.width, o.height);
				marker.solid = true;
				marker.immovable = true;
				state.markers.add(marker);
		}
	}

	public function loadImages()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around. 
			//			  This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}