function AllProgramsItem(label, icon, parent) {
    this._init(label, icon, parent);
}

AllProgramsItem.prototype = {
    __proto__: AppPopupSubMenuMenuItem.prototype,

    _init: function (label, icon, parent) {
        AppPopupSubMenuMenuItem.prototype._init.call(this, label);

        this.actor.set_style_class_name('');
        this.box = new St.BoxLayout({ style_class: 'menu-category-button' });
        this.parent = parent;
        //this.removeActor(this.label);
        this.label.destroy();
        //this.removeActor(this._triangle);
        this._triangle.destroy();
        this._triangle = new St.Label();
        this.label = new St.Label({
            text: " " + label
        });
        this.icon = new St.Icon({
            style_class: 'popup-menu-icon',
            icon_type: St.IconType.FULLCOLOR,
            icon_name: icon,
            icon_size: ICON_SIZE
        });
    this.box.add_actor(this.icon);
    this.box.add_actor(this.label);
        this.addActor(this.box);
    },

    setActive: function (active) {
        if (active) this.box.set_style_class_name('menu-category-button-selected');
        else this.box.set_style_class_name('menu-category-button');
    },

    _onButtonReleaseEvent: function (actor, event) {
        if (event.get_button() == 1) {
            this.activate(event);
        }
    },

    activate: function (event) {
        if (this.parent.leftPane.get_child() == this.parent.favsBox) this.parent.switchPanes("apps");
        else this.parent.switchPanes("favs");
    }
};

