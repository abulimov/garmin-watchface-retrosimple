import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Weather;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian;

class RetroSimpleFaceView extends WatchUi.WatchFace {
  private var timeFont, secondsFont, dateFont, stepsFont, batteryFont, iconsFont;
  function initialize() {
    timeFont = WatchUi.loadResource(Rez.Fonts.TimeFont);
    secondsFont = WatchUi.loadResource(Rez.Fonts.SecondsFont);
    dateFont = WatchUi.loadResource(Rez.Fonts.DateFont);
    stepsFont = WatchUi.loadResource(Rez.Fonts.StepsFont);
    batteryFont = WatchUi.loadResource(Rez.Fonts.BatteryFont);
    iconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
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
    dc.drawText(
      115,
      30,
      secondsFont,
      secondsString0,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      142,
      30,
      secondsFont,
      secondsString1,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
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
      weatherString = Lang.format("$1$C  $2$%", [
        weather.temperature.format("%d"),
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
    var hourString0 = (clockTime.hour / 10).format("%d");
    var hourString1 = (clockTime.hour % 10).format("%d");
    var minuteString0 = (clockTime.min / 10).format("%d");
    var minuteString1 = (clockTime.min % 10).format("%d");

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
    dc.drawText(
      -4,
      107,
      timeFont,
      hourString0,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      38,
      107,
      timeFont,
      hourString1,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      89,
      107,
      timeFont,
      minuteString0,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      131,
      107,
      timeFont,
      minuteString1,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      88,
      107,
      timeFont,
      ":",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // battery
    dc.drawText(
      72,
      10,
      iconsFont,
      batteryIcon,
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      100,
      10,
      batteryFont,
      batteryString,
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    // weather
    dc.drawText(
      99,
      27,
      dateFont,
      weatherString,
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    // notifications
    dc.drawText(
      15,
      47,
      iconsFont,
      notificationsString,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    // date
    dc.drawText(
      2,
      65,
      dateFont,
      dateString,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // steps
    dc.drawText(
      120,
      158,
      stepsFont,
      stepsString,
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    // steps icon
    dc.drawText(
      125,
      158,
      iconsFont,
      "s",
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
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
