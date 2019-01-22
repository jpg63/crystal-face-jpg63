using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;

class Indicators extends Ui.Drawable {

	private var mSpacingY;

	private var mIndicator1Type;
	private var mIndicator2Type;
	private var mIndicator3Type;

	// private enum /* INDICATOR_TYPES */ {
	// 	INDICATOR_TYPE_BLUETOOTH,
	// 	INDICATOR_TYPE_ALARMS,
	// 	INDICATOR_TYPE_NOTIFICATIONS,
	// 	INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS,
	// 	INDICATOR_TYPE_BATTERY
	// }

	function initialize(params) {
		Drawable.initialize(params);

		mSpacingY = params[:spacingY];

		onSettingsChanged();
	}

	function onSettingsChanged() {
		mIndicator1Type = App.getApp().getProperty("Indicator1Type");
		mIndicator2Type = App.getApp().getProperty("Indicator2Type");
		mIndicator3Type = App.getApp().getProperty("Indicator3Type");
	}

	function draw(dc) {
		var indicatorCount = App.getApp().getProperty("IndicatorCount");
		var tmplocX = locX;
		var tmplocY = 0;
		if (App.getApp().getProperty("DisplayJpg63") == true) { 
		  tmplocX = 180; 
		  tmplocY = 20;
		}
		if (indicatorCount == 3) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY - mSpacingY - tmplocY);
			drawIndicator(dc, mIndicator2Type, tmplocX, locY - tmplocY);
			drawIndicator(dc, mIndicator3Type, tmplocX, locY + mSpacingY - tmplocY);
		} else if (indicatorCount == 2) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY - (mSpacingY / 2));
			drawIndicator(dc, mIndicator2Type, tmplocX, locY + (mSpacingY / 2));
		} else if (indicatorCount == 1) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY);
		}
	}

	function drawIndicator(dc, indicatorType, x, y) {

		// Battery indicator.
		if (indicatorType == 4 /* INDICATOR_TYPE_BATTERY */) {
			if (Sys.getDeviceSettings().screenShape == Sys.SCREEN_SHAPE_ROUND) {
				drawBatteryMeter(dc, x, y, 24, 12);
			} else {
				drawBatteryMeter(dc, x, y, 20, 10);
			}
			return;
		}

		// Show notifications icon if connected and there are notifications, bluetoothicon otherwise.
		var settings = Sys.getDeviceSettings();
		if (indicatorType == 3 /* INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS */) {
			if (settings.phoneConnected && (settings.notificationCount > 0)) {
				indicatorType = 2; // INDICATOR_TYPE_NOTIFICATIONS
			} else {
				indicatorType = 0; // INDICATOR_TYPE_BLUETOOTH
			}
		}

		// Get value for indicator type.
		var value = [
			/* INDICATOR_TYPE_BLUETOOTH */ settings.phoneConnected,
			/* INDICATOR_TYPE_ALARMS */ settings.alarmCount > 0,
			/* INDICATOR_TYPE_NOTIFICATIONS */ settings.notificationCount > 0
		][indicatorType];

		var colour;
		if (value) {
		    if (App.getApp().getProperty("Theme") == THEME_COLOR_LIGHT) {
		      if ((indicatorType == 0) or (indicatorType == 3)) { // INDICATOR_TYPE_BLUETOOTH 
		        colour = Graphics.COLOR_DK_BLUE;
		      } else if (indicatorType == 1) { // INDICATOR_TYPE_ALARMS
		        colour = gThemeColour;  ///Graphics.Graphics.COLOR_YELLOW;
		      } else if (indicatorType == 2) { // INDICATOR_TYPE_NOTIFICATIONS
		        colour = gThemeColour;   //Graphics.COLOR_YELLOW;
		      } else {
		        colour = Graphics.COLOR_RED;
		      }
		    } else {
			  colour = gThemeColour;
			}
		} else {
			colour = gMeterBackgroundColour;
		}
		dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

		// Icon.
		dc.drawText(
			x,
			y,
			gIconsFont,
			["8", ":", "5"][indicatorType], // Get icon font char for indicator type.
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}
}
