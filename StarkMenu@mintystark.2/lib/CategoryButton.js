function CategoryButton(app) {
    this._init(app);
}

CategoryButton.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function(category) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this, {hover: false});

        this.actor.set_style_class_name('menu-category-button');
        var label;
        if (category) {
            var icon = category.get_icon();
            if (icon && icon.get_names)
                this.icon_name = icon.get_names().toString();
            else
                this.icon_name = "";
            label = category.get_name();
        } else
            label = _("All Applications");

        this.actor._delegate = this;
        this.label = new St.Label({ text: label, style_class: 'menu-category-button-label' });
        if (category && this.icon_name) {
            this.icon = new St.Icon({icon_name: this.icon_name, icon_size: CATEGORY_ICON_SIZE, icon_type: St.IconType.FULLCOLOR});
            this.addActor(this.icon);
        }
        this.addActor(this.label);
    }
};

