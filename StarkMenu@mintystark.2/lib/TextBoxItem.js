function TextBoxItem(label, icon, func, parent, hoverIcon) {
    this._init(label, icon, func, parent, hoverIcon);
}

TextBoxItem.prototype = {
    __proto__: AppPopupSubMenuMenuItem.prototype,

    _init: function (label, icon, func, parent, hoverIcon) {
        this.parent = parent;
        this.hoverIcon = hoverIcon;
        this.icon = icon;
        this.func = func;
        this.active = false;
        AppPopupSubMenuMenuItem.prototype._init.call(this, label);

        this.actor.set_style_class_name('menu-category-button');
        this.actor.add_style_class_name('menu-text-item-button');
        this.actor.connect('leave-event', Lang.bind(this, this._onLeaveEvent));
        //this.removeActor(this.label);
        this.label.destroy();
        //this.removeActor(this._triangle);
       
        this._triangle.destroy();
        this._triangle = new St.Label();
        this.label_text = label;

        this.label_icon = new St.Icon({icon_name: this.icon, icon_size: 18, icon_type: St.IconType.FULLCOLOR,});
        this.addActor(this.label_icon);
        this.label = new St.Label({
            text: this.label_text,
            style_class: 'menu-category-button-label'
        });
        this.addActor(this.label);
    },

    _update : function(quicklinkOptions){

        this.removeActor(this.label_icon);
        this.removeActor(this.label);

        if(quicklinkOptions == 'both' || quicklinkOptions == 'icons')
        {
            this.name_icon = new St.Icon({icon_name: this.icon, icon_size: (quicklinkOptions == 'icons' ? 26 : 18), icon_type: St.IconType.FULLCOLOR,});

            var iconFileName = this.icon;
            var iconFile = Gio.file_new_for_path(iconFileName);
            var icon;

            if (iconFile.query_exists(null)) {
                icon = new Gio.FileIcon({file: iconFile});
            } else {
                icon = new Gio.ThemedIcon({name: this.icon});
            }

            this.label_icon.set_gicon (icon);
            this.label_icon.set_icon_size((quicklinkOptions == 'icons' ? 26 : 18));

            if (!iconFile.query_exists(null)) {
                this.label_icon = this.name_icon;

            }

            this.addActor(this.label_icon);
        }

        if(quicklinkOptions == 'both' || quicklinkOptions == 'labels')
        {
            this.label = new St.Label({
                text: this.label_text,
                style_class: 'menu-category-button-label'
            });
            this.addActor(this.label);
        }
    },

    _onLeaveEvent : function(){
        this.hoverIcon.showUser = true;
        Tweener.addTween(this, {
           time: 1,
           onComplete: function () {
              if(!this.active){
                this.hoverIcon._onUserChanged();
              }
           }
        });
    },

    setActive: function (active) {
        if (active) {
            this.hoverIcon.showUser = false;
            this.actor.set_style_class_name('menu-category-button-selected');
            if(this.parent.quicklinkOptions != 'icons')
            {
                this.hoverIcon._refresh(this.icon);
            }
        } else this.actor.set_style_class_name('menu-category-button');
    },

    _onButtonReleaseEvent: function (actor, event) {
        if (event.get_button() == 1) {
            this.activate(event);
        }
    },

    activate: function (event) {
        eval(this.func);
        this.parent.close();
    }
};

