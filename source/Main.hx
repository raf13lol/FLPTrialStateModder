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
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Path;
import hl.UI;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.ui.MouseCursor;
import sys.io.File;

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

	var overwriteButton:FlxUICheckBox;

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

	var overwriteFlp(default, set):Bool = true;

	override public function create()
	{
		if (FlxG.save.data.overwrite == null)
		{
			FlxG.save.data.overwrite = true;
			FlxG.save.flush();
		}
		else
			overwriteFlp = FlxG.save.data.overwrite;

		bgColor = 0xFFF4FF81;

		var bg = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF000000, 0x90000000, 0x00000000]));
		insert(0, bg);

		var sizetoscale = FlxPoint.get(1, 1);
		var padding = 5;
		var offsetY = 100;

		var untrialbutton = new FunnyButton(0, 0, "Untrial-ize FLP/FST", sizetoscale, function()
		{
			untrial = true;
			flpFile = new FileReference(); // make it new and existing
			flpFile.addEventListener(Event.SELECT, flp); // add if people confirm
			flpFile.addEventListener(Event.CANCEL, nomoreevents); // add if people say nah
			flpFile.browse([
				new FileFilter("FL Studio Project files (*.flp).", "flp"),
				new FileFilter("FL Studio Preset files (*.fst).", "fst")
			]); // start that file selecter B)
		});
		add(untrialbutton);

		var trial = new FunnyButton(0, 0, "Trial-ize FLP/FST", sizetoscale, function()
		{
			untrial = false;
			flpFile = new FileReference(); // make it new and existing
			flpFile.addEventListener(Event.SELECT, flp); // add if people confirm
			flpFile.addEventListener(Event.CANCEL, nomoreevents); // add if people say nah
			flpFile.browse([
				new FileFilter("FL Studio Project files (*.flp).", "flp"),
				new FileFilter("FL Studio Preset files (*.fst).", "fst")
			]); // start that file selecter B)
		});
		add(trial);

		overwriteButton = new FlxUICheckBox(50, 100, null, null, "Toggle overwriting mode", 100, null, function()
		{
			overwriteFlp = overwriteButton.checked;
		});

		// ignore code below just trying to make it look good with bigger buttons

		untrialbutton.screenCenter();
		untrialbutton.x -= untrialbutton.width + padding;
		untrialbutton.y += offsetY;

		trial.screenCenter();
		trial.x += trial.width + padding;
		trial.y += offsetY;

		overwriteButton.scale.scale(1.2, 1.2);
		// overwriteButton.updateHitbox(); why the hell does this fuck up the checkbox position
		overwriteButton.textX += 15;
		overwriteButton.y = untrialbutton.y - overwriteButton.height - 20;

		add(overwriteButton);

		FlxG.sound.play("assets/sounds/startup.wav"); // play that ding sound
		super.create();
	}

	function nomoreevents(e) // stands for no untrial flp events
	{
		flpFile.removeEventListener(Event.SELECT, null); // if them people cancel it / did it
		flpFile.removeEventListener(Event.CANCEL, null); // ^
		flpFile = null;
	}

	function flp(e)
	{
		@:privateAccess
		{
			var path = flpFile.__path; // get that path
			if (path == null || !sys.FileSystem.exists(path) || (!path.endsWith(".flp") && !path.endsWith(".fst")))
			{
				return;
			} // check it aint broken
			var flp = sys.io.File.getBytes(path); // yoink the bytes

			// hopefully flp.length is the same as flp.b.length

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
						+ "TRIALED MODE.fst";
				else
					newpath = path.split(".flp").splice(0, path.split(".flp").length - 1).join("")
						+ " - "
						+ ((untrial) ? "NON-" : "")
						+ "TRIALED MODE.flp";
			}
			sys.io.File.saveBytes(newpath, flp); // save it
			yayyoudidit(); // display happy text :D
			nomoreevents(null);
		}
	}

	function yayyoudidit()
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
		var text = new FlxText(0, 0, 0, "Nice! Test it out to see if it works!", 28);
		text.alignment = CENTER;
		text.color = FlxColor.GREEN;
		text.screenCenter();
		text.y += 200;
		add(text);
		FlxTween.tween(text, {alpha: 0}, 1, {
			onComplete: function(_)
			{
				remove(text, true);
				text.destroy();
				text = null;
			},
			onUpdate: function(_)
			{
				text.y -= 1.25;
			}
		});
	}

	function set_overwriteFlp(value:Bool)
	{
		FlxG.save.data.overwrite = value;
		return overwriteFlp = value;
	}
}
