function FavoritesButton(appsMenuButton, app, nbFavorites, iconSize) {
    this._init(appsMenuButton, app, nbFavorites, iconSize);
}

FavoritesButton.prototype = {
    __proto__: GenericApplicationButton.prototype,

    _init: function(appsMenuButton, app, nbFavorites, iconSize) {
        GenericApplicationButton.prototype._init.call(this, appsMenuButton, app, true);
        var monitorHeight = Main.layoutManager.primaryMonitor.height;
        var real_size = (0.7*monitorHeight) / nbFavorites;
        var icon_size = iconSize;//0.6*real_size;
        if (icon_size>MAX_FAV_ICON_SIZE) icon_size = MAX_FAV_ICON_SIZE;
        this.actor.style = "padding-top: "+(icon_size/3)+"px;padding-bottom: "+(icon_size/3)+"px; margin:auto;"

        this.actor.add_style_class_name('menu-favorites-button');
        this.addActor(app.create_icon_texture(icon_size));

        this.label = new St.Label({ text: this.app.get_name(), style_class: 'menu-application-button-label' });
        this.addActor(this.label);

        this._draggable = DND.makeDraggable(this.actor);
        this.isDraggableApp = true;
    },

    get_app_id: function() {
        return this.app.get_id();
    },

    getDragActor: function() {
        return new Clutter.Clone({ source: this.actor });
    },

    // Returns the original actor that should align with the actor
    // we show as the item is being dragged.
    getDragActorSource: function() {
        return this.actor;
    }
};

