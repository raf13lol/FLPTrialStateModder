package;

import cpp.UInt8;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Path;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.io.File;

using StringTools;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
	}
}

class PlayState extends FlxState
{
	var untrialFile:FileReference;
	var trialFile:FileReference;
	var unlockArray = [[0xD0, 0x50], [0xF0, 0x70], [0xD1, 0x51], [0xC1, 0x41], [0xC8, 0x41]];

	override public function create()
	{
		var bg = new FlxSprite().loadGraphic("assets/bg.png");
		bg.screenCenter();
		add(bg);
		var untrial = new FlxButton(0, 0, "Untrial-ize FLP", function()
		{
			untrialFile = new FileReference(); // make it new and existing
			untrialFile.addEventListener(Event.SELECT, uflp); // add if people confirm
			untrialFile.addEventListener(Event.CANCEL, nuf); // add if people say nah
			untrialFile.browse([new FileFilter("FL Studio Project files (*.flp).", "flp")]); // start that file selecter B)
		});
		add(untrial);
		var trial = new FlxButton(0, 0, "Trial-ize FLP", function()
		{
			trialFile = new FileReference(); // make it new and existing
			trialFile.addEventListener(Event.SELECT, tflp); // add if people confirm
			trialFile.addEventListener(Event.CANCEL, ntf); // add if people say nah
			trialFile.browse([new FileFilter("FL Studio Project files (*.flp).", "flp")]); // start that file selecter B)
		});
		add(trial);
		var sizetoscale = 3.0;
		var extraoffset = 30;
		// ignore code below just trying to make it look good with bigger buttons
		untrial.scale.set(sizetoscale, sizetoscale);
		untrial.label.scale.set(sizetoscale, sizetoscale);
		untrial.updateHitbox();
		untrial.label.updateHitbox();
		untrial.screenCenter();
		untrial.x -= untrial.width + extraoffset;
		trial.scale.set(sizetoscale, sizetoscale);
		trial.label.scale.set(sizetoscale, sizetoscale);
		trial.updateHitbox();
		trial.label.updateHitbox();
		trial.screenCenter();
		trial.x += trial.width + extraoffset;
		super.create();
	}

	function nuf(e) // stands for no untrial flp events
	{
		untrialFile.removeEventListener(Event.SELECT, null); // if them people cancel it / did it
		untrialFile.removeEventListener(Event.CANCEL, null); // ^
	}

	function ntf(e) // stands for no trial flp events
	{
		trialFile.removeEventListener(Event.SELECT, null); // if them people cancel it / did it
		trialFile.removeEventListener(Event.CANCEL, null); // ^
	}

	function uflp(e) // untrial flp
	{
		@:privateAccess
		var path = untrialFile.__path; // get that path
		if (path == null || !sys.FileSystem.exists(path) || !path.endsWith(".flp"))
		{
			return;
		} // check it aint broken
		var flp = bytesToIntArray(sys.io.File.getBytes(path)); // yoink the bytes
		for (i in 0...flp.length) // set trial header thing to 01
		{
			if (flp[i] == 0x1c)
			{
				flp[i + 1] = 0x01;
				break;
			}
		}
		for (i in 0...flp.length) // detect 00 00 00 D4 34 and set the flag to correct value
		{
			if (flp[i] == 0x00 && flp[i + 1] != null && flp[i + 2] != null && flp[i + 3] != null && flp[i + 4] != null)
			{
				if (flp[i + 1] == 0x00 && flp[i + 2] == 0x00 && flp[i + 3] == 0xD4 && flp[i + 4] == 0x34)
				{
					for (j in i...i + 25)
					{
						for (k in 0...unlockArray.length)
						{
							if (flp[j] == unlockArray[k][0])
								flp[j] = unlockArray[k][1];
						}
					}
				}
			}
		}
		sys.io.File.saveBytes(path, intArrayToBytes(flp)); // save it
		yayyoudidit(); // display happy text :D
		nuf(null);
	}

	function bytesToIntArray(bytes:Bytes)
	{
		var array:Array<Null<cpp.UInt8>> = [];
		for (i in 0...bytes.length)
		{
			@:privateAccess
			array.push(bytes.b[i]);
		}
		return array;
	}

	function intArrayToBytes(array:Array<UInt8>)
	{
		@:privateAccess
		var bytes:Bytes = new Bytes(array.length, []);
		for (i in 0...array.length)
		{
			@:privateAccess
			bytes.b[i] = array[i];
		}
		return bytes;
	}

	function tflp(e) // trial flp
	{
		@:privateAccess
		var path = trialFile.__path; // get that path
		if (path == null || !sys.FileSystem.exists(path) || !path.endsWith(".flp"))
		{
			return;
		} // check it aint broken
		var flp = bytesToIntArray(sys.io.File.getBytes(path)); // yoink the bytes
		for (i in 0...flp.length) // set trial header thing to 01
		{
			if (flp[i] == 0x1c)
			{
				flp[i + 1] = 0x00;
				break;
			}
		}
		for (i in 0...flp.length) // detect 00 00 00 D4 34 and set the flag to correct value
		{
			if (flp[i] == 0x00 && flp[i + 1] != null && flp[i + 2] != null && flp[i + 3] != null && flp[i + 4] != null)
			{
				if (flp[i + 1] == 0x00 && flp[i + 2] == 0x00 && flp[i + 3] == 0xD4 && flp[i + 4] == 0x34)
				{
					for (j in i...i + 25)
					{
						for (k in 0...unlockArray.length)
						{
							if (flp[j] == unlockArray[k][1])
								flp[j] = unlockArray[k][0];
						}
					}
				}
			}
		}
		sys.io.File.saveBytes(path, intArrayToBytes(flp)); // save it
		yayyoudidit(); // display da happy text :)
		ntf(null);
	}

	function yayyoudidit()
	{
		FlxG.sound.play("assets/ding.wav"); // play that ding sound
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
}
