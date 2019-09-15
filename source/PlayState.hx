package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

class PlayState extends FlxState
{
	public var level:Level;
	public var pickups:FlxGroup;	
	public var enemies:FlxGroup;
	public var explosions:FlxGroup;
	public var markers:FlxGroup;	
	public var player:Player;
	public var playerProjectiles:FlxTypedGroup<PlayerShot>;
	public var livesIcon:FlxSprite;
	private var scoreText:FlxSprite;
	private var bonusText:FlxSprite;
	private var levelText:FlxSprite;
	private var hudGroup:FlxTypedGroup<FlxSprite>;
	private var levelCompletedText:FlxSprite;
	private var gameOverShadowText:FlxSprite;
	private var gameOverText:FlxSprite;
	private var scoreTextValue:FlxBitmapText;
	private var livesText:FlxBitmapText;
	private var bonusTextValue:FlxBitmapText;
	private var levelTextValue:FlxBitmapText;
	private var bonusCountTimer:Float = 0;
	private var scoreFont:FlxBitmapFont;
	private var bonusTimerInterval:Float = 0.25;
	private var bonusTimer:Float = 0;
	private var levelComplete:Bool = false;
	private var gameOverPlayed:Bool = false;
	private var gameOverTimer:Float = 0;
	private var startTimer:Float = 4;
	private var waveDelayTimer:Float = 0;
	private var bonusCounter:Int = 0;
	
	override public function create():Void
	{
		Globals.globalGameState = this;
		Globals.resetWaveVariables();

		player = new Player(0, 0, this);
		enemies = new FlxGroup();
		pickups = new FlxGroup();
		explosions = new FlxGroup();
		markers = new FlxGroup();
		hudGroup = new FlxTypedGroup<FlxSprite>();
		playerProjectiles = new FlxTypedGroup<PlayerShot>(10);

		// Load the level 
		level = new Level();

		add(enemies);
		add(pickups);
		add(explosions);
		
		level.loadEntities();
		
		var XMLFontData = Xml.parse(Assets.getText("assets/fonts/Score.fnt"));
		scoreFont = FlxBitmapFont.fromAngelCode("assets/fonts/Score_0.png", XMLFontData);
		
		scoreText = new FlxSprite(10, 10, "assets/images/ScoreText.png");
		add(scoreText);
		
		bonusText = new FlxSprite(250, 10, "assets/images/BonusText.png");
		add(bonusText);
		
		levelText = new FlxSprite(426, 10, "assets/images/LevelText.png");
		add(levelText);
		
		scoreTextValue = new FlxBitmapText(scoreFont);
		scoreTextValue.setPosition(100, 10); 
		scoreTextValue.text = StringTools.lpad(Std.string(Globals.playerScore), "0", 8);
		hudGroup.add(scoreTextValue);	
		
		bonusTextValue = new FlxBitmapText(scoreFont);
		bonusTextValue.setPosition(340, 10); 
		bonusTextValue.text = StringTools.lpad(Std.string(Globals.playerBonusValue), "0", 4);
		hudGroup.add(bonusTextValue);	
		
		levelTextValue = new FlxBitmapText(scoreFont);
		levelTextValue.setPosition(512, 10); 
		levelTextValue.text = StringTools.lpad(Std.string(Globals.currentLevel), "0", 2);
		hudGroup.add(levelTextValue);	

		for (i in 0...Globals.playerLives)
		{
			livesIcon = new FlxSprite();
			livesIcon.loadGraphic("assets/images/LivesIcon.png", false, 16, 14, false);
			livesIcon.setPosition(560 + (i * 18), 12);
			hudGroup.add(livesIcon);
		}
		
		add(hudGroup);
		
		// Initialize player projectiles pool
		var playerShot:PlayerShot;
		for (i in 0...10)
		{
			playerShot = new PlayerShot();
			playerProjectiles.add(playerShot);
			playerShot.kill();
		}
		
		add(playerProjectiles);
		add(player);
		
		levelCompletedText = new FlxSprite();
		levelCompletedText.loadGraphic("assets/images/Completed.png", true, 160, 32);
		levelCompletedText.animation.add("default", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 18, true);
		levelCompletedText.setPosition(FlxG.width / 2 - levelCompletedText.width / 2, FlxG.height - (levelCompletedText.height * 2));
		levelCompletedText.animation.play("default");
		levelCompletedText.visible = false;
		add(levelCompletedText);
		
		gameOverShadowText = new FlxSprite(0, 0, "assets/images/GameOverOutline.png");
		gameOverShadowText.setPosition(FlxG.width / 2 - gameOverShadowText.width / 2, FlxG.height / 2 - gameOverShadowText.height / 2);
		gameOverShadowText.visible = false;
		add(gameOverShadowText);
		
		gameOverText = new FlxSprite(0, 0, "assets/images/GameOverCenter.png");
		gameOverText.setPosition(FlxG.width / 2 - gameOverText.width / 2, FlxG.height / 2 - gameOverText.height / 2);
		gameOverText.visible = false;
		add(gameOverText);
		
		super.create();
	}
	
	override public function destroy():Void
	{
		enemies.destroy();
		player.destroy();
		pickups.destroy();
		markers.destroy();
		explosions.destroy();
		playerProjectiles = null;
		scoreText = null;
		scoreTextValue = null;
		livesIcon = null;
		livesText = null;
		levelCompletedText = null;
		gameOverShadowText = null;
		gameOverText = null;
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		ColorCycler.Update(elapsed);
		
		if (levelComplete)
		{
			if (Globals.playerBonusValue > 0)
			{
				bonusCountTimer += elapsed;
				if (bonusCountTimer > 0.01)
				{
					Globals.playerBonusValue -= 10;
					if (Globals.playerBonusValue <= 0)
						Globals.playerBonusValue = 0;
					Globals.playerScore += 10;
					bonusCounter++;
					bonusCountTimer = 0;
					if (bonusCounter > 2)
					{
						FlxG.sound.play("Count");
						bonusCounter = 0;
					}
					updateHUD();
				}
			}
			else
			{
				waveDelayTimer += elapsed;
				if (waveDelayTimer > 1)
				{
					waveDelayTimer = 0;
					Globals.currentLevel++;
					FlxG.switchState(new IntermissionState());
				}
			}
			
			level.tileMap.backgroundLayer.update(elapsed);
			
			return;
		}
		
		super.update(elapsed);
		updateHUD();
		
		if (Globals.gameOver)
		{
			if (!gameOverPlayed)
			{
				//gameOverSound.play();
				gameOverPlayed = true;
			}
			
			gameOverTimer += elapsed;
			if (gameOverTimer > 6)
			{
				gameOverTimer = 0;
				FlxG.switchState(new TitleState());
			}
			
			explosions.update(elapsed);
			gameOverText.color = ColorCycler.RedPulse;
			gameOverShadowText.visible = true;
			gameOverText.visible = true;
			return;
		}
		
		if (Globals.playerBonusValue > 0)
		{
			bonusTimer += elapsed;
			if (bonusTimer >= bonusTimerInterval)
			{
				bonusTimer = 0;
				Globals.playerBonusValue -= 10;
				if (Globals.playerBonusValue <= 0)
					Globals.playerBonusValue = 0;
			}
			
			if (Globals.playerBonusValue < 1000 && Globals.playerBonusValue > 0)
				bonusTextValue.color = ColorCycler.RedPulse;
			else
				bonusTextValue.color = 0xFFFFFFFF;
		}
		
		// Collide with foreground tile layer
		level.tileMap.collideWithLevel(player);
		//FlxG.overlap(enemies, enemies, onEnemyOverlap, collisionCheck);
		FlxG.collide(enemies, enemies, onEnemyOverlap);
		
		for (i in 0...pickups.length)
		{
			var pickup = cast(pickups.members[i], FlxSprite);
			
			if (!pickup.alive)
				continue;	
				
			if (FlxCollision.pixelPerfectCheck(player, pickup))	
				getPickup(pickup);
		}
		
		for (i in 0...playerProjectiles.length)
		{
			var projectile = playerProjectiles.members[i];
			
			if (!projectile.alive)
				continue;
				
			// Roll through enemies list here and do a pixel perfect check
			for (j in 0...enemies.length)
			{
				var entity = cast(enemies.members[j], FlxSprite);

				if (!entity.alive)
					continue;	
				
				if (FlxCollision.pixelPerfectCheck(projectile, entity))	
				{
					projectile.kill();
					var entityName = Type.getClassName(Type.getClass(entity));
					if (entityName == "Blob" || entityName == "Eggshell")
					{
						FlxG.sound.play("Freeze");	
						var enemy = cast(entity, Entity);
						enemy.changeState(Entity.State.FROZEN);
					}
					else
					{
						FlxG.sound.play("Hit");
					}
				}
			}
		}
		
		for (i in 0...enemies.length)
		{
			var entity = cast(enemies.members[i], FlxSprite);

			if (!entity.alive)
				continue;	
				
			if (FlxCollision.pixelPerfectCheck(player, entity))	
			{
				var enemy = cast(entity, Entity);
				if (enemy.currentState != Entity.State.FROZEN && enemy.currentState != Entity.State.THAWING)
					killPlayer();
				else
				{
					// kill enemy
					explosions.add(new IceExplosion(enemy.x + enemy.origin.x - 30, enemy.y + enemy.origin.y - 30));
					FlxG.sound.play("IceBreak");
					Globals.playerScore += enemy.scoreValue;
					enemy.kill();
				}
			}
		}
	}
	
	private function killPlayer():Void
	{
		player.changeState(Entity.State.DEAD);
	}
	
	private function freezeAll():Void
	{
		for (i in 0...enemies.length)
		{
			var entity = cast(enemies.members[i], FlxSprite);

			if (!entity.alive)
				continue;	
				
			var enemy = cast(entity, Entity);
			var enemyType = Type.getClassName(Type.getClass(entity));
			if (enemyType == "Bomber")
			{
				var bomber = cast(enemy, Bomber);
				bomber.explode(null);
			}
			else if (enemyType != "Snowball")
			{
				explosions.add(new IceExplosion(enemy.x + enemy.origin.x - 30, enemy.y + enemy.origin.y - 30));
				enemy.changeState(Entity.State.FROZEN);
			}
		}		
	}

	private function getPickup(item:FlxObject):Void
	{
		var pickup:Pickup = cast(item, Pickup);
		if (pickup.type == Pickup.PickupType.POW)
		{
			FlxG.camera.flash(0xFFFFFFFF, 0.1);
			FlxG.sound.play("Freeze");	
			freezeAll();
		}
		else if (pickup.type == Pickup.PickupType.EXTRA_LIFE)
		{
			FlxG.sound.play("ExtraLife");
			Globals.playerLives++;
			levelComplete = true;
		}
		else if (pickup.type == Pickup.PickupType.SILVER_COIN || pickup.type == Pickup.PickupType.GOLD_COIN)
		{
			FlxG.sound.play("PickupCoin");
			Globals.playerScore += pickup.scoreValue;
		}
		else if (pickup.type == Pickup.PickupType.FISH)
		{
			FlxG.sound.play("PickupFish", 0.5);
			Globals.playerScore += pickup.scoreValue;					
		}
		else if (pickup.type == Pickup.PickupType.SILVER_STAR)
		{
			
		}
		else if (pickup.type == Pickup.PickupType.GOLD_STAR)
		{
			
		}
		else if (pickup.type == Pickup.PickupType.SUPER_STAR)
		{
			
		}

		item.kill();
	}
	
	private function collisionCheck(obj1:FlxObject, obj2:FlxObject):Bool
	{
		var obj1 = cast(obj1, FlxSprite);
		var obj2 = cast(obj2, FlxSprite);
		
		if (FlxG.pixelPerfectOverlap(obj1, obj2))
			return true;
		else
			return false;
	}
	
	private function onEnemyOverlap(obj1:FlxObject, obj2:FlxObject):Bool
	{
		var obj1 = cast(obj1, Entity);
		var obj2 = cast(obj2, Entity);
		
		var entityClassNameObj1 = Type.getClassName(Type.getClass(obj1));
		var entityClassNameObj2 = Type.getClassName(Type.getClass(obj2));
		
		if (entityClassNameObj1 == "SnowBall")
		{
			obj2.kill();
			return false;
		} 
		else if (entityClassNameObj2 == "SnowBall")
		{
			obj1.kill();
			return false;
		} 

		//FlxObject.separate(obj1, obj2);
		
		if (obj1.currentState != Entity.State.EXPLODING)
			obj1.changeRandomDirection();
			
		if (obj2.currentState != Entity.State.EXPLODING)
			obj2.changeRandomDirection();
		
		return true;
	}
	
	private function updateHUD():Void
	{
		scoreTextValue.text = StringTools.lpad(Std.string(Globals.playerScore), "0", 8);
		bonusTextValue.text = StringTools.lpad(Std.string(Globals.playerBonusValue), "0", 4);
	}

	private static function floatToStringPrecision(num:Float, prec:Int)
	{
		num = Math.round(num * Math.pow(10, prec));
		var str = '' + num;
		var len = str.length;
		
		if (len <= prec)
		{
			while (len < prec)
			{
			  str = '0' + str;
			  len++;
			}
			
			return '00.' + str;
		}
		else
			return StringTools.lpad(str.substr(0, str.length - prec), "0", 2) + '.' + str.substr(str.length - prec);
	}
}