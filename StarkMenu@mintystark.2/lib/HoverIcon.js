function HoverIcon(parent) {
    this._init(parent);
}

HoverIcon.prototype = {
    _init: function (parent) {
        this.actor = new St.Bin();
        this.icon = new St.Icon({
            icon_size: HOVER_ICON_SIZE,
            icon_type: St.IconType.FULLCOLOR,
            style_class: 'hover-icon'
        });
        this.actor.cild = this.icon;

        this.showUser = true;

        this.userBox = new St.BoxLayout({ style_class: 'hover-box', reactive: true, vertical: false });

        this._userIcon = new St.Icon({ style_class: 'hover-user-icon'});

        this.userBox.connect('button-press-event', Lang.bind(this, function() {
            parent.toggle();
            Util.spawnCommandLine("cinnamon-settings user");
        }));

        this._userIcon.hide();
        this.userBox.add(this.icon,
                    { x_fill:  true,
                      y_fill:  false,
                      x_align: St.Align.END,
                      y_align: St.Align.START });
        this.userBox.add(this._userIcon,
                    { x_fill:  true,
                      y_fill:  false,
                      x_align: St.Align.END,
                      y_align: St.Align.START });
        this.userLabel = new St.Label(({ style_class: 'hover-label'}));
        this.userBox.add(this.userLabel,
                    { x_fill:  true,
                      y_fill:  false,
                      x_align: St.Align.END,
                      y_align: St.Align.MIDDLE });

        var icon = new Gio.ThemedIcon({name: 'avatar-default'});
        this._userIcon.set_gicon (icon);
        this._userIcon.show();

        this._user = AccountsService.UserManager.get_default().get_user(GLib.get_user_name());
        this._userLoadedId = this._user.connect('notify::is_loaded', Lang.bind(this, this._onUserChanged));
        this._userChangedId = this._user.connect('changed', Lang.bind(this, this._onUserChanged));
        this._onUserChanged();

        //this._refresh('folder-home');
    },

    _onUserChanged: function() {
        if (this._user.is_loaded && this.showUser) {
            //this.set_applet_tooltip(this._user.get_real_name());
            this.userLabel.set_text (this._user.get_real_name());
            if (this._userIcon) {
                var iconFileName = this._user.get_icon_file();
                var iconFile = Gio.file_new_for_path(iconFileName);
                var icon;
                if (iconFile.query_exists(null)) {
                    icon = new Gio.FileIcon({file: iconFile});
                } else {
                    icon = new Gio.ThemedIcon({name: 'avatar-default'});
                }
                this._userIcon.set_gicon (icon);
                this.icon.hide();
                this._userIcon.show();
            }
        }
    },

    _refresh: function (icon) {
        this._userIcon.hide();

        var iconFileName = icon;
        var iconFile = Gio.file_new_for_path(iconFileName);
        var newicon;

        if (iconFile.query_exists(null)) {
            newicon = new Gio.FileIcon({file: iconFile});
        } else {
            newicon = new Gio.ThemedIcon({name: icon});
        }

        if (iconFile.query_exists(null)) {
            this.icon.set_gicon (newicon);
        }
        else
        {
            this.icon.set_icon_name(icon);
        }

        this.icon.show();
    }
};

