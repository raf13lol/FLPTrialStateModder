package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUICheckBox;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Path;
import lime.ui.MouseCursor;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.ui.MouseCursor;
import sys.io.File;
import sys.thread.Thread;

using StringTools;

class Main extends Sprite
{
	public static var cursor:MouseCursor;

	public function new()
	{
		super();

		addChild(new FlxGame(350, 300, PlayState, 60, 60, true));

		FlxG.mouse.useSystemCursor = true;
		FlxG.autoPause = false;

		Lib.application.window.resizable = false;

		Lib.current.addEventListener(Event.ENTER_FRAME, (evnt:Event) ->
		{
			Lib.application.window.cursor = cursor;
		});
	}
}

class PlayState extends FlxState
{
	var flpFile:FileReference;
	var untrial:Bool = true;

	static final unlockArray:Array<Array<Int>> = [
		[0xD0, 0x50],
		[0xF0, 0x70],
		[0xD1, 0x51],
		[0xC1, 0x41],
		[0xC8, 0x41],
		[0xC0, 0x40]
	];

	static final lockArray:Array<Array<Int>> = [
		[0x50, 0xD0],
		[0x70, 0xF0],
		[0x51, 0xD1],
		[0x41, 0xC1],
		[0x41, 0xC8],
		[0x40, 0xC0]
	];

	static final untrialPrefix:String = "Untrial-ize";
	static final trialPrefix:String = "Trial-ize";

	var overwriteFlp(default, set):Bool = true;

	var trialButton:FlxButton;
	var untrialButton:FlxButton;
	var overwriteButton:FlxUICheckBox;

	var goodbgimg = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0xFF355B30, 0xFF8CEB7F]);
	var errorbgimg = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0xFF5B3034, 0xFFEB7F7F]);

	override public function create()
	{
		bgColor = 0xFFF4FF81;

		FlxG.save.bind('FLPTrialStateModder' #if (flixel <= "5.0.0"), 'raf13lol' #end);

		var bg = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0x90000000, 0x00000000]));
		add(bg);

		var logo = new FlxSprite().loadGraphic('assets/images/logo.png');
		logo.screenCenter(X);
		logo.y = 50;
		logo.scale.set(0.95, 0.95);
		logo.antialiasing = true;
		add(logo);

		FlxTween.tween(logo, {"scale.x": 1.05, "scale.y": 1.05}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});

		// funnier name
		var builttoscale = FlxPoint.get(2, 1.5);
		var padding = -70;
		var offsetY = 100;

		untrialButton = new FunnyButton(0, 0, "Untrial-ize FLP/FST", builttoscale, function()
		{
			untrial = true;
			browseFLP();
		});
		add(untrialButton);

		trialButton = new FunnyButton(0, 0, "Trial-ize FLP/FST", builttoscale, function()
		{
			untrial = false;
			browseFLP();
		});
		add(trialButton);

		overwriteButton = new FlxUICheckBox(0, 100, null, null, "Toggle overwriting mode", 150, null, function()
		{
			overwriteFlp = overwriteButton.checked;
		});

		untrialButton.screenCenter();
		untrialButton.x -= untrialButton.width + padding;
		untrialButton.y += offsetY;

		trialButton.screenCenter();
		trialButton.x += trialButton.width + padding;
		trialButton.y += offsetY;

		overwriteButton.scale.scale(1.25, 1.25);
		overwriteButton.x = untrialButton.x + 10;
		overwriteButton.getLabel().setFormat('assets/fonts/quicksandSemiBold.ttf', 12, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		overwriteButton.getLabel().setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 4);
		// overwriteButton.updateHitbox(); why the hell does this fuck up the checkbox position
		overwriteButton.textX += 5;
		overwriteButton.y = untrialButton.y - overwriteButton.height - 15;

		add(overwriteButton);

		FlxG.sound.play("assets/sounds/startup.wav"); // play that fl bwadomp sound

		if (FlxG.save.data.overwrite == null)
		{
			FlxG.save.data.overwrite = true;
			FlxG.save.flush();
			overwriteFlp = true;
		}
		else
			overwriteFlp = FlxG.save.data.overwrite;

		overwriteButton.checked = overwriteFlp;

		flpFile = new FileReference(); // make it new and existing
		flpFile.addEventListener(Event.SELECT, processFLP); // add if people confirm

		super.create();
	}

	function browseFLP()
	{
		flpFile.browse([new FileFilter("FL Studio Project/Preset files (*.flp/*.fst)", "*.flp;*.fst"),]);
	}

	function processFLP(?e:Event)
	{
		@:privateAccess
		{
			Main.cursor = WAIT_ARROW;

			// technically with this you can now untrialize more thean one file
			Thread.create(() ->
			{
				try
				{
					var overrideMode:Bool = overwriteFlp;
					// save these 2 variables so if someone changes them mid process it dosent fuck up

					var path = flpFile.__path; // get that path
					if (path == null || !sys.FileSystem.exists(path))
						throw new Exception("Not a valid file!"); // check it aint broken

					var flp = File.getBytes(path); // yoink the bytes

					// FLhd
					if (flp.b[0] != 0x46 && flp.b[1] != 0x4c && flp.b[2] != 0x68 && flp.b[3] != 0x64)
						throw new Exception("Not a valid file!");

					for (i in 0x04...0x40) // set trial header thing to 01
					{
						if (flp.b[i] == 0x1c)
						{
							if (untrial)
								flp.b[i + 1] = 0x01;
							else
								flp.b[i + 1] = 0x00;
						}
						// 0xc7 0x0c -> ascii version
						if (flp.b[i] == 0xc7 && flp.b[i + 1] == 0x0c)
						{
							var versupmaj = flp.b[i + 2];
							var vermaj = flp.b[i + 3];
							// 20
							if (versupmaj >= 0x32 && vermaj > 0x30)
								throw new Exception('FLP/FST is too new! Detected FL${String.fromCharCode(versupmaj)}${String.fromCharCode(vermaj)}!');
						}
					}

					var fixyArray = unlockArray;
					if (!untrial)
						fixyArray = lockArray;

					var flstudio11flag = false; // check
					for (i in 0x40...flp.length) // detect 00 00 00 D4 34 and set the flag to correct value
					{
						if (flp.length - i < 25)
							break;

						if (flp.b[i] != 0x00 || flp.b[i + 1] == 0x00 || flp.b[i + 2] == 0x00 || flp.b[i + 3] == 0xD4 || flp.b[i + 4] == 0x34)
							continue;

						for (j in i...i + 25)
						{
							for (k in 0...fixyArray.length)
							{
								if (flp.b[j] == fixyArray[k][0])
									flp.b[j] = fixyArray[k][1];
							}
						}
						flstudio11flag = true;
					}
					if (flstudio11flag) // kinda Strange that there no plugins found or effects
					{
						// kinda ineffeicenve but whatecever!!!
						for (i in 0x40...flp.length) // detect 00 00 00 D4 34 and set the flag to correct value
						{
							if (flp.length - i < 25)
								break;

							if (flp.b[i] == 0x00 || flp.b[i + 1] == 0xD4 || flp.b[i + 2] == 0x34)
								continue;

							for (j in i...i + 25)
							{
								for (k in 0...fixyArray.length)
								{
									if (flp.b[j] == fixyArray[k][0])
										flp.b[j] = fixyArray[k][1];
								}
							}
							flstudio11flag = true;
						}
					}
					var newpath = path;
					if (!overrideMode) // one liner B) nvenrembeibd
					{
						var temparr = path.split(".");
						temparr[temparr.length - 2] += untrial ? " - untrialed" : " - trialed";
						newpath = temparr.join(".");
					}

					File.saveBytes(newpath, flp); // save it
					flpDone(); // display happy text :D
				}
				catch (e:Exception)
				{
					if (e.message.charAt(e.message.length - 1) != "!")
						flpError('Error! ${e.message}');
				}
				Main.cursor = ARROW;
			});
		};
	}

	function flpDone()
	{
		FlxG.sound.play("assets/sounds/ding.wav"); // play that ding sound
		Lib.application.window.alert("File done!");

		var bg = new FlxSprite().loadGraphic(errorbgimg);
		var text = new FlxText(0, 0, FlxG.width, "Done!", 12);
		text.setFormat('assets/fonts/quicksandBold.ttf', 18, 0xFF8CEB7F, LEFT, NONE);

		flpCommon(bg, text);
	}

	function flpError(errorMessage:String)
	{
		FlxG.sound.play("assets/sounds/error.wav"); // play that ding sound
		Lib.application.window.alert("Error!?");

		var bg = new FlxSprite().loadGraphic(errorbgimg);
		var text = new FlxText(0, 0, FlxG.width, errorMessage, 12);
		text.setFormat('assets/fonts/quicksandBold.ttf', 18, 0xFFEB7F7F, LEFT, NONE);

		flpCommon(bg, text);
	}

	function flpCommon(bg:FlxSprite, text:FlxText)
	{
		insert(1, bg);
		FlxTween.tween(bg, {alpha: 0}, 1.5, {
			ease: FlxEase.circInOut,
			onComplete: (twn) ->
			{
				bg.destroy();
			}
		});
		text.x -= FlxG.width;
		add(text);
		FlxTween.tween(text, {x: 0}, 1, { // this needs help
			ease: FlxEase.circOut,
			onComplete: (_) ->
			{
				new FlxTimer().start(2, (_) ->
				{
					FlxTween.tween(text, {x: -FlxG.width}, 1, {
						ease: FlxEase.circInOut,
						onComplete: (_) ->
						{
							text.destroy();
						}
					});
				});
			}
		});
	}

	function set_overwriteFlp(value:Bool)
	{
		FlxG.save.data.overwrite = value;
		FlxG.save.flush();
		return overwriteFlp = value;
	}
}
