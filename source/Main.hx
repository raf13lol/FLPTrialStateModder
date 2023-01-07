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
		#if (flixel >= "5.0.0")
		addChild(new FlxGame(0, 0, PlayState, 60, 60, true));
		#else
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
		#end
		FlxG.save.bind('FLPTrialStateModder' #if (flixel <= "5.0.0"), 'RafPlayz69YT' #end);

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

	static final untrialPrefix:String = "Untial-ize";
	static final trialPrefix:String = "Tial-ize";

	var overwriteFlp(default, set):Bool = true;
	var fstMode(default, set):Bool = false;

	var trialButton:FlxButton;
	var untrialButton:FlxButton;
	var overwriteButton:FlxUICheckBox;
	var fstButton:FlxUICheckBox;

	override public function create()
	{
		bgColor = 0xFFF4FF81;

		var bg = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0x90000000, 0x00000000]));
		insert(0, bg);

		var logo = new FlxSprite().loadGraphic('assets/images/logo.png');
		logo.screenCenter(X);
		logo.y = 50;
		logo.scale.set(0.95, 0.95);
		FlxTween.tween(logo, {"scale.x": 1.05, "scale.y": 1.05}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});
		logo.antialiasing = true;
		add(logo);

		var sizetoscale = FlxPoint.get(2, 1.5);
		var padding = -70;
		var offsetY = 100;

		untrialButton = new FunnyButton(0, 0, "Untrial-ize FLP", sizetoscale, function()
		{
			untrial = true;
			browseFLP();
		});
		add(untrialButton);

		trialButton = new FunnyButton(0, 0, "Trial-ize FLP", sizetoscale, function()
		{
			untrial = false;
			browseFLP();
		});
		add(trialButton);

		overwriteButton = new FlxUICheckBox(0, 100, null, null, "Toggle overwriting mode", 150, null, function()
		{
			overwriteFlp = overwriteButton.checked;
		});

		fstButton = new FlxUICheckBox(0, 100, null, null, "Toggle FST mode", 150, null, function()
		{
			fstMode = fstButton.checked;
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

		fstButton.scale.scale(1.25, 1.25);
		fstButton.x = trialButton.x + 10;
		fstButton.getLabel().setFormat('assets/fonts/quicksandSemiBold.ttf', 12, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		fstButton.getLabel().setBorderStyle(OUTLINE, FlxColor.BLACK, 2, 4);
		// fstButton.updateHitbox(); why the hell does this fuck up the checkbox position
		fstButton.textX += 5;
		fstButton.y = trialButton.y - fstButton.height - 15;

		add(fstButton);

		FlxG.sound.play("assets/sounds/startup.wav"); // play that fl bwadomp sound
		FlxG.sound.playMusic('assets/music/kindaAmbientSong.wav', 0);
		FlxG.sound.music.fadeIn(1, 0, 0.7);
		Lib.application.window.onFocusIn.add(() ->
		{
			FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, 0.7);
		});
		Lib.application.window.onFocusOut.add(() ->
		{
			FlxG.sound.music.fadeOut(1, 0);
		});

		if (FlxG.save.data.overwrite == null)
		{
			FlxG.save.data.overwrite = true;
			FlxG.save.flush();
		}
		else
			fstMode = FlxG.save.data.overwrite;

		if (FlxG.save.data.fst == null)
		{
			FlxG.save.data.fst = false;
			FlxG.save.flush();
		}
		else
			overwriteFlp = FlxG.save.data.fst;

		overwriteButton.checked = overwriteFlp;
		fstButton.checked = fstMode;

		super.create();
	}

	function removeEvents(?e:Event) // Bruh, Take this one! Like, really take this one. No more flpFile! No more events! No more Filereference events! No more FLP files! You've been removed!
	{ // -me

		flpFile.removeEventListener(Event.SELECT, null); // if them people cancel it / did it
		flpFile.removeEventListener(Event.CANCEL, null); // ^
		flpFile = null;
	}

	function browseFLP()
	{
		flpFile = new FileReference(); // make it new and existing
		flpFile.addEventListener(Event.SELECT, processFLP); // add if people confirm
		flpFile.addEventListener(Event.CANCEL, removeEvents); // add if people say nah
		if (fstMode)
			flpFile.browse([new FileFilter("FL Studio Preset file (*.fst)", "*.fst")]);
		else
			flpFile.browse([new FileFilter("FL Studio Project file (*.flp)", "*.flp")]);
		// start that file selecter B)
	}

	function processFLP(?e:Event)
	{
		@:privateAccess Main.cursor = WAIT_ARROW;

		// technically with this you can now untrialize more thean one file
		Thread.create(() ->
		{
			try
			{
				@:privateAccess
				{
					var path = flpFile.__path; // get that path
					if (path == null || !sys.FileSystem.exists(path) || (!path.endsWith(".flp") && !path.endsWith(".fst")))
					{
						throw new Exception("Not a valid file!");
					} // check it aint broken
					var flp = File.getBytes(path); // yoink the bytes

					var fixyArray = unlockArray;
					if (!untrial)
						fixyArray = lockArray;

					var flstudio11flag = 0; // check
					for (i in 0x30...flp.length) // detect 00 00 00 D4 34 and set the flag to correct value
					{
						if (flp.b[i] == 0x00 && flp.b[i + 1] == 0x00 && flp.b[i + 2] == 0x00 && flp.b[i + 3] == 0xD4 && flp.b[i + 4] == 0x34)
						{
							for (j in i...i + 25)
							{
								for (k in 0...fixyArray.length)
								{
									if (flp.b[j] == fixyArray[k][0])
									{
										flp.b[j] = fixyArray[k][1];
									}
								}
							}
							flstudio11flag++;
						}

						if (flp.length - i < 20)
							break;
					}
					if (flstudio11flag == 0) // kinda sus that there no plugins found or effects
					{
						for (i in 0x30...flp.length) // detect 00 D4 34 and set the flag to correct value
						{
							if (flp.b[i] == 0x00 && flp.b[i + 1] == 0xD4 && flp.b[i + 2] == 0x34)
							{
								for (j in i...i + 25)
								{
									for (k in 0...fixyArray.length)
									{
										if (flp.b[j] == fixyArray[k][0])
										{
											flp.b[j] = fixyArray[k][1];
										}
									}
								}
								flstudio11flag++;
							}

							if (flp.length - i < 20)
								break;
						}
					} // kinda ineffeicenve but whatecever!!!
					for (i in 0...0x30) // set trial header thing to 01
					{
						if (flp.b[i] == 0x1c)
						{
							if (untrial)
								flp.b[i + 1] = 0x01;
							else
								flp.b[i + 1] = 0x00;
						}
					}
					var newpath = path;
					if (!overwriteFlp) // one liner B) nvenrembeibd
					{
						if (path.endsWith(".fst"))
							newpath = path.split(".fst").splice(0, path.split(".fst").length - 1).join("")
								+ " - "
								+ ((untrial) ? "NON-" : "")
								+ "TRIAL MODE.fst";
						else
							newpath = path.split(".flp").splice(0, path.split(".flp").length - 1).join("")
								+ " - "
								+ ((untrial) ? "NON-" : "")
								+ "TRIAL MODE.flp";
					}
					@:privateAccess Main.cursor = ARROW;
					File.saveBytes(newpath, flp); // save it
					flpDone(); // display happy text :D
					removeEvents();
				}
			}
			catch (e:Exception)
			{
				flpError(e.message);
			}
		});
	}

	function flpDone()
	{
		FlxG.sound.play("assets/sounds/ding.wav"); // play that ding sound
		var bg = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0xFF355B30, 0xFF8CEB7F]));
		insert(1, bg);
		FlxTween.tween(bg, {alpha: 0}, 1.5, {
			ease: FlxEase.circInOut,
			onComplete: (twn) ->
			{
				bg.destroy();
			}
		});
		Lib.application.window.alert();
		var text = new FlxText(0, 0, FlxG.width, "Done! Test it out to see if it works!", 12);
		text.x -= FlxG.width;
		text.setFormat('assets/fonts/quicksandBold.ttf', 18, 0xFF8CEB7F, LEFT, NONE);
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

	function flpError(errorMessage:String)
	{
		FlxG.sound.play("assets/sounds/error.wav"); // play that ding sound
		var bg = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0xFF5B3034, 0xFFEB7F7F]));
		insert(1, bg);
		FlxTween.tween(bg, {alpha: 0}, 1.5, {
			ease: FlxEase.circInOut,
			onComplete: (twn) ->
			{
				bg.destroy();
			}
		});
		Lib.application.window.alert();
		var text = new FlxText(0, 0, FlxG.width, 'Something went wrong :( Error message: $errorMessage', 12);
		text.x -= FlxG.width;
		text.setFormat('assets/fonts/quicksandBold.ttf', 18, 0xFFEB7F7F, LEFT, NONE);
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

	function set_fstMode(value:Bool)
	{
		var mode = (value ? "FST" : "FLP");
		FlxG.save.data.fst = value;
		FlxG.save.flush();
		untrialButton.text = '$untrialPrefix $mode';
		trialButton.text = '$trialPrefix $mode';
		return fstMode = value;
	}
}
