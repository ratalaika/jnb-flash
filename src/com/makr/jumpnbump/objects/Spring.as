﻿package com.makr.jumpnbump.objects
{
	import org.flixel.*;	
	
	public class Spring	extends FlxSprite
	{
		
		/// Individual level assets
		// original level
		[Embed(source = '../../../../../data/levels/original/spring.png')] private var ImgSpringOriginal:Class;
		[Embed(source = '../../../../../data/levels/original/sounds.swf', symbol="Spring")] private var SoundSpringOriginal:Class;
		
		private var ImgSpring:Class;
		private var SoundSpring:Class;
		
		public function Spring(X:Number,Y:Number):void
		{
			switch (FlxG.levels[1])
			{
				case "original":
				default:
					ImgSpring = ImgSpringOriginal;
					SoundSpring = SoundSpringOriginal;
					break;
			}

			super(X, Y);
			loadGraphic(ImgSpring, true, true, 16, 12); // load player sprite (is animated, is reversible, is 19x19)
			
            // set bounding box
            width = 16;
            height = 12;
			
            offset.x = 0;  //Where in the sprite the bounding box starts on the X axis
            offset.y = 8;  //Where in the sprite the bounding box starts on the Y axis

			// set animations for everything the bunny can do
			addAnimation("idle", [5]);
			addAnimation("sproing", [0, 1, 2, 3, 4, 5], 20, false);
			addAnimationCallback(CallbackTest);

			play("idle");
		}
		
		public function Activate():void
		{
			play("idle");
			play("sproing");
			FlxG.play(SoundSpring);
		}
		
		private function CallbackTest(name:String, frameNumber:uint, frameIndex:uint):void
		{
			if (name == "sproing" && frameNumber == 5)
				play("idle");
		}
	}
}