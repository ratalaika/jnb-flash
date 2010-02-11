﻿package com.makr.jumpnbump.objects
{
	import com.makr.jumpnbump.PlayState;
	import flash.geom.Point;
	import org.flixel.*;	

	public class Gib extends FlxSprite
	{
		
		/// Individual level assets
		// witch level
		[Embed(source = '../../../../../data/levels/witch/gore.png')] private var ImgGibWitch:Class;

		// original level
		[Embed(source = '../../../../../data/levels/original/gore.png')] private var ImgGibOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/blood.png')] private var ImgBloodOriginal:Class;
		
		
		private var ImgGib:Class;
		private var ImgBlood:Class;
		
		private static const _STATIC_PERCENTAGE:uint = 8;
		private var _gravity:Number = 150;
		private var _numBloodSprites:uint = 6;
		private var _blood:FlxEmitter;
		private var _force:Number = 200;
		private var _static:Boolean = false;
		private var _bleeding:Boolean = true;
		private var _killTimer:Number = 0;
		private var _isSwimming:Boolean = false;
		
		public function Gib(PlayerID:uint, Kind:String, X:Number, Y:Number, Static:Boolean=false, Bleeding:Boolean=true, Xvel:Number = 0, Yvel:Number = 0 ):void
		{
			switch (FlxG.levels[1])
			{
				case "witch":
					ImgGib = ImgGibWitch;
					ImgBlood = ImgBloodOriginal;
					break;

				case "original":
				default:
					ImgGib = ImgGibOriginal;
					ImgBlood = ImgBloodOriginal;
					break;
			}

			_static = Static;
			_bleeding = Bleeding;
			super(X, Y);
			loadGraphic(ImgGib, true, false, 5, 5); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 3;
            height = 3;
			
			drag.x = 25;
			
            maxVelocity.x = 100;
            maxVelocity.y = 200;

			acceleration.y = _gravity;
			
			if (Xvel == 0 && Yvel == 0)
			{
				velocity.x = (Math.random() - 0.5 ) * _force;
				velocity.y = (Math.random() - 0.5 ) * _force;
			}
			else
			{
				velocity.x = Xvel;
				velocity.y = Yvel;
			}
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 0;  //Where in the sprite the bounding box starts on the Y axis

			// set up the blood emitter
			
			if (_bleeding)
			{
				_blood = PlayState.gParticles.add(new FlxEmitter (X, Y)) as FlxEmitter;
				_blood.createSprites(ImgBlood, _numBloodSprites, 0, true);
				_blood.gravity = 0;
				_blood.setRotation( -30, 30);
				_blood.start(false, 0, 0.05);
			}

			
			// set sprites
			var sO:uint = PlayerID * 8;
			addAnimation("Fur0", [0+sO]);
			addAnimation("Fur1", [1+sO]);
			addAnimation("Fur2", [2+sO]);
			addAnimation("Fur3", [3+sO]);
			addAnimation("Fur4", [4+sO]);
			addAnimation("Fur5", [5+sO]);
			addAnimation("Fur6", [6+sO]);
			addAnimation("Fur7", [7+sO]);
			addAnimation("Flesh", [32]);
			
						
			
			var animationName:String;
			switch (Kind) 
			{
				case "Fur":
					animationName = "Fur" + FlxU.floor(Math.random()*8).toString();
					break;
					
				case "Flesh":
					animationName = "Flesh";
					break;
			}
			
			play(animationName);
		}
		
		public function isSwimming():Boolean { return _isSwimming; }
		public function setSwimming(isSwimming:Boolean):void
		{
			if (_isSwimming == isSwimming)	// return if value is already set
				return;
				
			_isSwimming = isSwimming;		// set value
			
			if (isSwimming)	
			{
				maxVelocity.x *= 0.3
				maxVelocity.y *= 0.2;
			}
			else
			{
				maxVelocity.x *= 3.333
				maxVelocity.y *= 5;
			}
		}

		public function makeStatic():void
		{
			_static = true;
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 0;
			if (_bleeding)
				_blood.kill();
		}
		
		public override function update():void
		{
			if (_static)
				return;
				
			angularVelocity = velocity.x * 22.9183118;	// degrees/sec
			
			// Velocity.x in pixels/sec * 360 degrees / (5 pixels diameter * PI) == Velocity.x in pixels/sec * 22.9183118 degrees/pixel

			if (_bleeding)
			{
				_blood.x = x + 2;
				_blood.y = y + 2;
				
				
				_blood.setXSpeed(velocity.x * 0.2, velocity.x*0.6);
				_blood.setYSpeed(velocity.y * 0.2, velocity.y*0.6);
			}
			
			if (x < 0 || x > 352)
			{
				velocity.x *= -.3;
			}
			
			if (y > 250)
			{
				velocity.y = 0;
				acceleration.y = 0;
			}

			if (velocity.x == 0 && velocity.y  == 0)
			{
				_killTimer += FlxG.elapsed;
			}
			
			if (_killTimer > 1 )
			{
				
				if (Math.random() * 100 < _STATIC_PERCENTAGE)	// [_STATIC_PERCENTAGE]% chance of becoming static
				{
					makeStatic();
					trace("INFO: Gib: A gib was made static.");
				}
				else
					kill();
			
			}
						
			super.update();
		}
		
		public override function hitLeft(Contact:FlxObject,Velocity:Number):void
		{
			velocity.x *= -Math.random();
		}

		public override function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			if (velocity.y > 10)
				velocity.y *= -0.25;
			else
				velocity.y = 0;
		}

		public override function kill():void
		{
			if (_bleeding)
				_blood.kill();
			super.kill();
		}
	}
}