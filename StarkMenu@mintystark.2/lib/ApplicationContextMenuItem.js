function ApplicationContextMenuItem(appButton, label, action) {
    this._init(appButton, label, action);
}

ApplicationContextMenuItem.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function (appButton, label, action) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this, {focusOnHover: false});

        this._appButton = appButton;
        this._action = action;
        this.label = new St.Label({ text: label });
        this.addActor(this.label);
    },

    activate: function (event) {
        switch (this._action){
            case "add_to_panel":
                var winListApplet = false;
                try {
                    winListApplet = imports.ui.appletManager.applets['WindowListGroup@jake.phy@gmail.com'];
                } catch (e) {}
                if (winListApplet) winListApplet.applet.GetAppFavorites().addFavorite(this._appButton.app.get_id());
                else {
                    var settings = new Gio.Settings({ schema: 'org.cinnamon' });
                    var desktopFiles = settings.get_strv('panel-launchers');
                    desktopFiles.push(this._appButton.app.get_id());
                    settings.set_strv('panel-launchers', desktopFiles);
                    if (!Main.AppletManager.get_object_for_uuid("panel-launchers@cinnamon.org")){
                        var new_applet_id = global.settings.get_int("next-applet-id");
                        global.settings.set_int("next-applet-id", (new_applet_id + 1));
                        var enabled_applets = global.settings.get_strv("enabled-applets");
                        enabled_applets.push("panel1:right:0:panel-launchers@cinnamon.org:" + new_applet_id);
                        global.settings.set_strv("enabled-applets", enabled_applets);
                    }
                }
                break;
            case "add_to_desktop":
                var file = Gio.file_new_for_path(this._appButton.app.get_app_info().get_filename());
                var destFile = Gio.file_new_for_path(USER_DESKTOP_PATH+"/"+this._appButton.app.get_id());
                try{
                    file.copy(destFile, 0, null, function(){});
                    // Need to find a way to do that using the Gio library, but modifying the access::can-execute attribute on the file object seems unsupported
                    Util.spawnCommandLine("chmod +x \""+USER_DESKTOP_PATH+"/"+this._appButton.app.get_id()+"\"");
                }catch(e){
                    global.log(e);
                }
                break;
            case "add_to_favorites":
                AppFavorites.getAppFavorites().addFavorite(this._appButton.app.get_id());
                break;
            case "remove_from_favorites":
                AppFavorites.getAppFavorites().removeFavorite(this._appButton.app.get_id());
                break;
        }
        this._appButton.toggleMenu();
        return false;
    }

};

