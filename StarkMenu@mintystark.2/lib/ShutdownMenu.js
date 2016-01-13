function ShutdownMenu(parent, hoverIcon) {
    this._init(parent, hoverIcon);
}

ShutdownMenu.prototype = {
    __proto__: AppPopupSubMenuMenuItem.prototype,

    _init: function (parent, hoverIcon) {
        var label = '';
        this.hoverIcon = hoverIcon;
        this.parent = parent;
        AppPopupSubMenuMenuItem.prototype._init.call(this, label);
        this.actor.set_style_class_name('menu-category-button');
        //this.removeActor(this.label);
        this.label.destroy();
        //this.removeActor(this._triangle);
        this._triangle.destroy();
        this._triangle = new St.Label();
        this.icon = new St.Icon({
            style_class: 'popup-menu-icon',
            icon_type: St.IconType.FULLCOLOR,
            icon_name: 'forward',
            icon_size: ICON_SIZE
        });
        this.addActor(this.icon);

        this.menu = new PopupMenu.PopupSubMenu(this.actor);
        this.menu.actor.remove_style_class_name("popup-sub-menu");

        var menuItem;
        menuItem = new ShutdownContextMenuItem(this.parent, this.menu, _("Logout"), "logout");
        this.menu.addMenuItem(menuItem);
        menuItem = new ShutdownContextMenuItem(this.parent, this.menu, _("Lock Screen"), "lock");
        this.menu.addMenuItem(menuItem);

    },

    setActive: function (active) {
        if (active) {
            this.actor.set_style_class_name('menu-category-button-selected');
            this.hoverIcon._refresh('system-log-out');
        } else this.actor.set_style_class_name('menu-category-button');
    },

    _onButtonReleaseEvent: function (actor, event) {
        if (event.get_button() == 1) {
            this.menu.toggle();
        }

    }
};

