function RightButtonsBox(appsMenuButton, menu) {
    this._init(appsMenuButton, menu);
}

RightButtonsBox.prototype = {
    _init: function (appsMenuButton, menu) {
        this.appsMenuButton = appsMenuButton;
        this.actor = new St.BoxLayout();
        this.itemsBox = new St.BoxLayout({
            vertical: true
        });
        this.shutDownMenuBox = new St.BoxLayout({
            vertical: true
        });
        this.shutDownIconBox = new St.BoxLayout({
            vertical: true
        });
        this.shutdownBox = new St.BoxLayout({
            vertical: false
        });
        this.actor._delegate = this;
        this.menu = menu;
        this.addItems();
        this._container = new Cinnamon.GenericContainer();
        this.actor.add_actor(this._container);
        this._container.connect('get-preferred-height', Lang.bind(this, this._getPreferredHeight));
        this._container.connect('get-preferred-width', Lang.bind(this, this._getPreferredWidth));
        this._container.connect('allocate', Lang.bind(this, this._allocate));
        this._container.add_actor(this.itemsBox);
    },

    _update_quicklinks : function(quicklinkOptions) {

        for(var i in this.quicklinks)
        {
            this.quicklinks[i]._update(quicklinkOptions);
        }
        this.shutdown._update(quicklinkOptions);
        this.logout._update(quicklinkOptions);
        this.lock._update(quicklinkOptions);

        if(quicklinkOptions == 'icons')
        {
            this.hoverIcon.userLabel.hide();
            this.hoverIcon._userIcon.set_icon_size(22);
            this.hoverIcon.icon.set_icon_size(22);
            this.shutDownMenuBox.set_style('min-height: 1px');
            this.shutdownMenu.actor.hide();
            this.shutdownBox.remove_actor(this.shutdownMenu.actor);

        }
        else
        {
            this.hoverIcon.userLabel.show();
            this.hoverIcon._userIcon.set_icon_size(HOVER_ICON_SIZE);
            this.hoverIcon.icon.set_icon_size(HOVER_ICON_SIZE);
            this.shutDownIconBox.hide();
            this.shutdownMenu.actor.show();
            this.shutDownMenuBox.set_style('min-height: 82px');
            this.shutdownBox.add_actor(this.shutdownMenu.actor);
        }
    },

    addItems: function () {

        this.itemsBox.destroy_all_children();
        this.shutdownBox.destroy_all_children();

        this.hoverIcon = new HoverIcon(this.menu);
        this.itemsBox.add_actor(this.hoverIcon.userBox);

        this.quicklinks = [];
        for(var i in this.menu.quicklinks)
        {
            if(this.menu.quicklinks[i] != '')
            {
                if(this.menu.quicklinks[i] == 'separator')
                {
                    this.separator = new PopupMenu.PopupSeparatorMenuItem();
                    this.separator.actor.set_style("padding: 0em 0em; min-width: 1px;");

                    this.itemsBox.add_actor(this.separator.actor);
                }
                else
                {
                    var split = this.menu.quicklinks[i].split(',');
                    if(split.length == 3)
                    {
                        this.quicklinks[i] = new TextBoxItem(_(split[0]), split[1], "Util.spawnCommandLine('"+split[2]+"')", this.menu, this.hoverIcon, false);
                        this.itemsBox.add_actor(this.quicklinks[i].actor);
                    }
                }
            }
        }

        this.shutdown = new TextBoxItem(_("Shutdown"), "system-shutdown", "Session.ShutdownRemote()", this.menu, this.hoverIcon, false);
        this.logout = new TextBoxItem(_("Logout"), "gnome-logout", "Session.LogoutRemote(0)", this.menu, this.hoverIcon, false);

        var screensaver_settings = new Gio.Settings({ schema: "org.cinnamon.desktop.screensaver" });
        var screensaver_dialog = Gio.file_new_for_path("/usr/bin/cinnamon-screensaver-command");
        if (screensaver_dialog.query_exists(null)) {
            if (screensaver_settings.get_boolean("ask-for-away-message"))
            {
                this.lock = new TextBoxItem(_("Lock"), "gnome-lockscreen", "Util.spawnCommandLine('cinnamon-screensaver-lock-dialog')", this.menu, this.hoverIcon, false);
            }
            else
            {
                this.lock = new TextBoxItem(_("Lock"), "gnome-lockscreen", "Util.spawnCommandLine('cinnamon-screensaver-command --lock')", this.menu, this.hoverIcon, false);
            }
        }

        this.shutdownMenu = new ShutdownMenu(this.menu, this.hoverIcon);

        this.shutdownBox.add_actor(this.shutdown.actor);
        this.shutdownBox.add_actor(this.shutdownMenu.actor);

        this.shutDownMenuBox.add_actor(this.shutdownBox);
        this.shutDownMenuBox.add_actor(this.shutdownMenu.menu.actor);

        this.shutDownIconBox.add_actor(this.logout.actor);
        this.shutDownIconBox.add_actor(this.lock.actor);

        this.itemsBox.add_actor(this.shutDownMenuBox);
        this.shutDownMenuBox.set_style('min-height: 82px');

        this.itemsBox.add_actor(this.shutDownIconBox);
    },

    _getPreferredHeight: function (actor, forWidth, alloc) {
        var t = this.itemsBox.get_preferred_height(forWidth);
        var minSize = t[0];
        var naturalSize = t[1];
        alloc.min_size = minSize;
        alloc.natural_size = naturalSize;
    },

    _getPreferredWidth: function (actor, forHeight, alloc) {
        var t = this.itemsBox.get_preferred_width(forHeight);
        var minSize = t[0];
        var naturalSize = t[1];
        alloc.min_size = minSize;
        alloc.natural_size = naturalSize;
    },

    _allocate: function (actor, box, flags) {
        var childBox = new Clutter.ActorBox();

        var t = this.itemsBox.get_preferred_size();
        var minWidth = t[0];
        var minHeight = t[1];
        var naturalWidth = t[2];
        var naturalHeight = t[3];

        childBox.y1 = 0;
        childBox.y2 = childBox.y1 + naturalHeight;
        childBox.x1 = 0;
        childBox.x2 = childBox.x1 + naturalWidth;
        this.itemsBox.allocate(childBox, flags);

        var mainBoxHeight = this.appsMenuButton.mainBox.get_height();

        // [minWidth, minHeight, naturalWidth, naturalHeight] = this.shutDownItemsBox.get_preferred_size();

        // childBox.y1 = mainBoxHeight - 110;
        // childBox.y2 = childBox.y1;
        // childBox.x1 = 0;
        // childBox.x2 = childBox.x1 + naturalWidth;
        // this.shutDownItemsBox.allocate(childBox, flags);
    }
};

