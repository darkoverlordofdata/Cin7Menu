function ApplicationButton(appsMenuButton, app) {
    this._init(appsMenuButton, app);
}

ApplicationButton.prototype = {
    __proto__: GenericApplicationButton.prototype,

    _init: function(appsMenuButton, app) {
        GenericApplicationButton.prototype._init.call(this, appsMenuButton, app, true);
        this.category = new Array();
        this.actor.set_style_class_name('menu-application-button');
        this.icon = this.app.create_icon_texture(APPLICATION_ICON_SIZE);
        this.addActor(this.icon);
        this.name = this.app.get_name();
        this.label = new St.Label({ text: this.name, style_class: 'menu-application-button-label' });
        this.addActor(this.label);
        this._draggable = DND.makeDraggable(this.actor);
        this.isDraggableApp = true;
    },

    get_app_id: function() {
        return this.app.get_id();
    },

    getDragActor: function() {
        var favorites = AppFavorites.getAppFavorites().getFavorites();
        var nbFavorites = favorites.length;
        var monitorHeight = Main.layoutManager.primaryMonitor.height;
        var real_size = (0.7*monitorHeight) / nbFavorites;
        var icon_size = 0.6*real_size;
        if (icon_size>MAX_FAV_ICON_SIZE) icon_size = MAX_FAV_ICON_SIZE;
        return this.app.create_icon_texture(icon_size);
    },

    // Returns the original actor that should align with the actor
    // we show as the item is being dragged.
    getDragActorSource: function() {
        return this.actor;
    }
};

