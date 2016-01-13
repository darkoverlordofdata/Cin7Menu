function AppPopupSubMenuMenuItem() {
    this._init.apply(this, arguments);
}



AppPopupSubMenuMenuItem.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function(text, hide_expander) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this);

        this.actor.add_style_class_name('popup-submenu-menu-item');

        var table = new St.Table({ homogeneous: false,
                                      reactive: true });

        if (!hide_expander) {
            this._triangle = new St.Icon({ icon_name: "media-playback-start",
                                icon_type: St.IconType.SYMBOLIC,
                                style_class: 'popup-menu-icon' });

            table.add(this._triangle,
                    {row: 0, col: 0, col_span: 1, x_expand: false, x_align: St.Align.START});

            this.label = new St.Label({ text: text });
            this.label.set_margin_left(6.0);
            table.add(this.label,
                    {row: 0, col: 1, col_span: 1, x_align: St.Align.START});
        }
        else {
            this.label = new St.Label({ text: text });
            table.add(this.label,
                    {row: 0, col: 0, col_span: 1, x_align: St.Align.START});
        }
        this.actor.label_actor = this.label;
        this.addActor(table, { expand: true, span: 1, align: St.Align.START });

        this.menu = new PopupMenu.PopupSubMenu(this.actor, this._triangle);
        this.menu.connect('open-state-changed', Lang.bind(this, this._subMenuOpenStateChanged));
    },

    _subMenuOpenStateChanged: function(menu, open) {
        this.actor.change_style_pseudo_class('open', open);
    },

    destroy: function() {
        this.menu.destroy();
        PopupBaseMenuItem.prototype.destroy.call(this);
    },

    _onKeyPressEvent: function(actor, event) {
        var symbol = event.get_key_symbol();

        if (symbol == Clutter.KEY_Right) {
            this.menu.open(true);
            this.menu.actor.navigate_focus(null, Gtk.DirectionType.DOWN, false);
            return true;
        } else if (symbol == Clutter.KEY_Left && this.menu.isOpen) {
            this.menu.close();
            return true;
        }

        return PopupMenu.PopupBaseMenuItem.prototype._onKeyPressEvent.call(this, actor, event);
    },

    activate: function(event) {
        this.menu.open(true);
    },

    _onButtonReleaseEvent: function(actor) {
        this.menu.toggle();
    }
};

