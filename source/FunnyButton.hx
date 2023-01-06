package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.ui.MouseCursor;

enum ButtonState
{
	NORMAL;
	HIGHLIGHT;
	PRESSED;
}

class FunnyButton extends FlxButton
{
	public var state:ButtonState = NORMAL;

	public function new(x:Int, y:Int, text:String, scale:FlxPoint, ?onPress:Void->Void)
	{
		super(x, y, text, onPress);
		// loadGraphic('assets/images/button.png', false); todo
		onOver.sound = FlxG.sound.load("assets/sounds/buttonHover.wav", 1, false);

		label.setFormat('assets/fonts/quicksandSemiBold.ttf', 16, FlxColor.BLACK, CENTER);

		this.scale.scale(scale.x, scale.y + 1.2); // gosh i hate this
		updateHitbox();
		this.label.fieldWidth = width;
		// this.label.scale.scale(scale.x, scale.y);
		// this.label.scale.scale(1, scale.y);
		// label.updateHitbox();

		var labelHeight = label.height / 2;

		labelOffsets = [
			FlxPoint.get(0, labelHeight),
			FlxPoint.get(0, labelHeight),
			FlxPoint.get(0, labelHeight)
		];
	}

	// this entire part is stupid
	// why flixel...

	override function onOverHandler()
	{
		state = HIGHLIGHT;
		Main.cursor = MouseCursor.BUTTON;
		super.onOverHandler();
	}

	override function onOutHandler()
	{
		state = NORMAL;
		Main.cursor = MouseCursor.ARROW;
		super.onOutHandler();
	}

	override function onDownHandler()
	{
		state = PRESSED;
		super.onDownHandler();
	}

	override function onUpHandler()
	{
		state = HIGHLIGHT;
		super.onUpHandler();
	}
}
