function ShutdownContextMenuItem(parentMenu, menu, label, action) {
    this._init(parentMenu, menu, label, action);
}

ShutdownContextMenuItem.prototype = {
    __proto__: ApplicationContextMenuItem.prototype,

    _init: function (parentMenu, menu, label, action) {
        this.parentMenu = parentMenu;
        ApplicationContextMenuItem.prototype._init.call(this, menu, label, action);
        this._screenSaverProxy = new ScreenSaver.ScreenSaverProxy();
    },

    activate: function (event) {
        switch (this._action) {
        case "logout":
            Session.LogoutRemote(0);
            break;
        case "lock":
        var screensaver_settings = new Gio.Settings({ schema: "org.cinnamon.desktop.screensaver" });
                var screensaver_dialog = Gio.file_new_for_path("/usr/bin/cinnamon-screensaver-command");
                if (screensaver_dialog.query_exists(null)) {
                    if (screensaver_settings.get_boolean("ask-for-away-message")) {
                        Util.spawnCommandLine("cinnamon-screensaver-lock-dialog");
                    }
                    else {
                        Util.spawnCommandLine("cinnamon-screensaver-command --lock");
                    }
                }
                else {
                    this._screenSaverProxy.LockRemote();
                }
            break;
        }
        this._appButton.toggle();
        this.parentMenu.toggle();
        return false;
    }

};

