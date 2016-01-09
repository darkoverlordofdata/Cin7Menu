Lang = imports.lang
Applet = imports.ui.applet
GLib = imports.gi.GLib
Util = imports.misc.util
Gettext = imports.gettext.domain('cinnamon-applets')
_ = Gettext.gettext

class MyApplet
    __proto__: Applet.IconApplet.prototype

    constructor:(orientation)->
        @_init(orientation)
        
    _init:(orientation) ->
        Applet.IconApplet.prototype._init.call(this, orientation);
        try 
            @set_applet_icon_name("lock-computer")
            @set_applet_tooltip(_("Click here to test computer"))
            return
        
        catch e
            global.logError(e)
            return
            
    on_applet_clicked:(evtdata) ->
        notification = "notify-send \"this is a test\"  -a TEST -t 10 -u low"
        Util.spawnCommandLine(notification)
        return
        

main = (metadata, orientation)->
    myApplet = new MyApplet(orientation)
    return myApplet
