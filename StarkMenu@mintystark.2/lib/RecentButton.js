function RecentButton(appsMenuButton, file) {
    this._init(appsMenuButton, file);
}

RecentButton.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function(appsMenuButton, file) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this, {hover: false});
        this.file = file;
        this.appsMenuButton = appsMenuButton;
        this.button_name = this.file.name;
        this.actor.set_style_class_name('menu-application-button');
        this.actor._delegate = this;
        this.label = new St.Label({ text: this.button_name, style_class: 'menu-application-button-label' });
    this.label.clutter_text.ellipsize = Pango.EllipsizeMode.END;
        this.icon = file.createIcon(APPLICATION_ICON_SIZE);
        this.addActor(this.icon);
        this.addActor(this.label);
    },

    _onButtonReleaseEvent: function (actor, event) {
        if (event.get_button()==1){
            Gio.app_info_launch_default_for_uri(this.file.uri, global.create_app_launch_context());
            this.appsMenuButton.menu.close();
        }
    },

    activate: function(event) {
        Gio.app_info_launch_default_for_uri(this.file.uri, global.create_app_launch_context());
        this.appsMenuButton.menu.close();
    }
};

