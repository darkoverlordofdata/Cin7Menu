Applet = imports.ui.applet
GLib = imports.gi.GLib
Util = imports.misc.util
Gettext = imports.gettext.domain('cinnamon-applets')
_ = Gettext.gettext

class MyApplet
  __proto__: base = Applet.IconApplet.prototype

  name: 'Gracie'

  constructor:(orientation)->
    base._init.call(this, orientation);
    try
      @set_applet_icon_name("gnome-info")
      @set_applet_tooltip(_("Say Hello, #{@name}"))
      return

    catch e
      global.logError(e)
      return

  on_applet_clicked:(evtdata) =>
    notification = "notify-send \"Hello #{@name}\"  -a TEST -t 10 -u low"
    Util.spawnCommandLine(notification)
    return


main = (metadata, orientation)-> new MyApplet(orientation)
