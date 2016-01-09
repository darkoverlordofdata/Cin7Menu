class RecentClearButton
  __proto__: PopupMenu.PopupBaseMenuItem.prototype
  
  constructor:(appsMenuButton) ->
    @_init(appsMenuButton)
    
  _init:(appsMenuButton) ->
    PopupMenu.PopupBaseMenuItem.prototype._init.call(this, hover: false)
    @appsMenuButton = appsMenuButton
    @actor.set_style_class_name('menu-application-button')
    @button_name = _("Clear list")
    @actor._delegate = this
    @label = new St.Label(text: @button_name, style_class: 'menu-application-button-label')
    @icon = new St.Icon(icon_name: 'edit-clear', icon_type: St.IconType.SYMBOLIC, icon_size: APPLICATION_ICON_SIZE)
    @addActor(@icon)
    @addActor(@label)
    return

  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1
      @appsMenuButton.menu.close()
      GtkRecent = new Gtk.RecentManager()
      GtkRecent.purge_items()
    return

    