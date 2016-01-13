function RecentCategoryButton(app) {
    this._init(app);
}

RecentCategoryButton.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function(category) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this, {hover: false});
        this.actor.set_style_class_name('menu-category-button');
        this.actor._delegate = this;
        this.label = new St.Label({ text: _("Recent Files"), style_class: 'menu-category-button-label' });
        this.icon = new St.Icon({icon_name: "folder-recent", icon_size: CATEGORY_ICON_SIZE, icon_type: St.IconType.FULLCOLOR});
        this.addActor(this.icon);
        this.addActor(this.label);
    }
};

