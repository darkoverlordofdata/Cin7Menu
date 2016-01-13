function PlaceButton(appsMenuButton, place, button_name) {
    this._init(appsMenuButton, place, button_name);
}

PlaceButton.prototype = {
    __proto__: PopupMenu.PopupBaseMenuItem.prototype,

    _init: function(appsMenuButton, place, button_name) {
        PopupMenu.PopupBaseMenuItem.prototype._init.call(this, {hover: false});
        this.appsMenuButton = appsMenuButton;
        this.place = place;
        this.button_name = button_name;
        this.actor.set_style_class_name('menu-application-button');
        this.actor._delegate = this;
        this.label = new St.Label({ text: this.button_name, style_class: 'menu-application-button-label' });
        this.icon = place.iconFactory(APPLICATION_ICON_SIZE);
        this.addActor(this.icon);
        this.addActor(this.label);
    },

    _onButtonReleaseEvent: function (actor, event) {
        if (event.get_button()==1){
            this.place.launch();
            this.appsMenuButton.menu.close();
        }
    },

    activate: function(event) {
        this.place.launch();
        this.appsMenuButton.menu.close();
    }
};

