import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Weather;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian;

class RetroSimpleFaceView extends WatchUi.WatchFace {
  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  private function drawLabelText(
    dc as Dc,
    labelID as String,
    text as String
  ) as Void {
    var label = WatchUi.View.findDrawableById(labelID) as WatchUi.Text;
    label.setText(text);
    label.draw(dc);
  }

  // calls every second for partial update
  //
  function onPartialUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var clockTime = System.getClockTime();
    // want the digits closer to each other than font allows
    var secondsString0 = (clockTime.sec / 10).format("%d");
    var secondsString1 = (clockTime.sec % 10).format("%d");
    dc.setClip(113, 0, 62, 65);
    // seconds
    drawLabelText(dc, "SecondsLabel0", secondsString0);
    drawLabelText(dc, "SecondsLabel1", secondsString1);
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // device settings - we use time format and temperature units
    var sysSettings = System.getDeviceSettings();
    // Get the current time and date
    var clockTime = System.getClockTime();
    var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    // get steps counter
    var info = ActivityMonitor.getInfo();
    var steps = info.steps;
    // weather
    var weather = Weather.getCurrentConditions();
    var weatherString = "";
    if (weather != null) {
      var temp = weather.temperature;
      var tempLetter = "C";
      if (sysSettings.temperatureUnits != System.UNIT_METRIC) {
        temp = weather.temperature * 1.8 + 32;
        tempLetter = "F";
      }
      weatherString = Lang.format("$1$$2$ $3$%", [
        temp.format("%d"),
        tempLetter,
        weather.precipitationChance.format("%02d"),
      ]);
    }
    // battery
    var stats = System.getSystemStats();
    var batteryString = Lang.format("$1$d", [
      stats.batteryInDays.format("%02d"),
    ]);
    var batteryIcon = "h"; // full
    if (stats.battery <= 10) {
      batteryIcon = "k"; // low
    } else if (stats.battery <= 50) {
      batteryIcon = "m"; // half
    }

    // notifications/alarms
    var settings = System.getDeviceSettings();
    var notificationsString = "";
    if (settings.notificationCount != 0) {
      notificationsString = "n";
    }

    // time
    var hour = clockTime.hour;
    if (!sysSettings.is24Hour && hour > 12) {
      hour -= 12;
    }
    var hoursString0 = (hour / 10).format("%d");
    var hoursString1 = (hour % 10).format("%d");
    var minutesString0 = (clockTime.min / 10).format("%d");
    var minutesString1 = (clockTime.min % 10).format("%d");

    // date
    var dateString = Lang.format("$1$ $2$ $3$", [
      today.day_of_week,
      today.day.format("%02d"),
      today.month,
    ]).toUpper();
    var stepsString = Lang.format("$1$", [steps]);

    // re-draw the screen as it could have been affected by clipping we do to display seconds
    dc.clearClip();
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    // time, we want the digits closer to each other than font allows
    drawLabelText(dc, "HoursLabel0", hoursString0);
    drawLabelText(dc, "HoursLabel1", hoursString1);
    drawLabelText(dc, "MinutesLabel0", minutesString0);
    drawLabelText(dc, "MinutesLabel1", minutesString1);
    drawLabelText(dc, "ColonLabel", ":");
    // battery
    drawLabelText(dc, "BatteryIconLabel", batteryIcon);
    drawLabelText(dc, "BatteryLabel", batteryString);
    // weather
    drawLabelText(dc, "WeatherLabel", weatherString);
    // notifications
    drawLabelText(dc, "NotificationsLabel", notificationsString);
    // date
    drawLabelText(dc, "DateLabel", dateString);
    // steps
    drawLabelText(dc, "StepsLabel", stepsString);
    // steps icon
    drawLabelText(dc, "StepsIconLabel", "s");
    // draw seconds
    onPartialUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}
}
