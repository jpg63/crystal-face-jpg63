using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;

class Indicators extends Ui.Drawable {

	private var mSpacing;
	private var mIsHorizontal = false;

	private var mIndicator1Type;
	private var mIndicator2Type;
	private var mIndicator3Type;
	private var tmplocX;
    private var tmplocY;
	

	// private enum /* INDICATOR_TYPES */ {
	// 	INDICATOR_TYPE_BLUETOOTH,
	// 	INDICATOR_TYPE_ALARMS,
	// 	INDICATOR_TYPE_NOTIFICATIONS,
	// 	INDICATOR_TYPE_BLUETOOTH_OR_NOTIFICATIONS,
	// 	INDICATOR_TYPE_BATTERY
	// }

	function initialize(params) {
		Drawable.initialize(params);

		if (params[:spacingX] != null) {
			mSpacing = params[:spacingX];
			mIsHorizontal = true;
		} else {
			mSpacing = params[:spacingY];
		}		

		onSettingsChanged();
	}

	function onSettingsChanged() {
		mIndicator1Type = App.getApp().getProperty("Indicator1Type");
		mIndicator2Type = App.getApp().getProperty("Indicator2Type");
		mIndicator3Type = App.getApp().getProperty("Indicator3Type");
	}

	function draw(dc) {
		var indicatorCount = App.getApp().getProperty("IndicatorCount");
			
		if (App.getApp().getProperty("DisplayJpg63") == true) { 
		  tmplocX = 180; 
		  tmplocY = 20;
		} else {
  	      tmplocX = locX;
		  tmplocY = 0;
		}
			
		// Horizontal layout for rectangle-148x205.
		if (mIsHorizontal) {
			drawHorizontal(dc, indicatorCount);

		// Vertical layout for others.
		} else {
			drawVertical(dc, indicatorCount);
		}
	}

	(:horizontal_indicators)
	function drawHorizontal(dc, indicatorCount) {
		if (indicatorCount == 3) {
			drawIndicator(dc, mIndicator1Type, tmplocX - mSpacing, locY);
			drawIndicator(dc, mIndicator2Type, tmplocX, locY - tmplocY);
			drawIndicator(dc, mIndicator3Type, tmplocX + mSpacing, locY);
		} else if (indicatorCount == 2) {
			drawIndicator(dc, mIndicator1Type, tmplocX - (mSpacing / 2), locY);
			drawIndicator(dc, mIndicator2Type, tmplocX + (mSpacing / 2), locY);
		} else if (indicatorCount == 1) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY);
		}
	}

	(:vertical_indicators)
	function drawVertical(dc, indicatorCount) {
		if (indicatorCount == 3) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY - mSpacing - tmplocY);
			drawIndicator(dc, mIndicator2Type, tmplocX, locY - tmplocY);
			drawIndicator(dc, mIndicator3Type, tmplocX, locY + mSpacing - tmplocY);
		} else if (indicatorCount == 2) {
			drawIndicator(dc, mIndicator1Type, tmplocX, locY - (mSpacing / 2));
			drawIndicator(dc, mIndicator2Type, tmplocX, locY + (mSpacing / 2));
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
