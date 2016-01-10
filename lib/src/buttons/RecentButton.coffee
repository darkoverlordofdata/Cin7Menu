class RecentButton
  __proto__: PopupMenu.PopupBaseMenuItem.prototype
  
  constructor:(appsMenuButton, file) ->
    @_init(appsMenuButton, file)
    
  _init:(appsMenuButton, file) ->
    PopupMenu.PopupBaseMenuItem.prototype._init.call(this, hover: false)
    @file = file
    @appsMenuButton = appsMenuButton
    @button_name = @file.name
    @actor.set_style_class_name('menu-application-button')
    @actor._delegate = this
    @label = new St.Label(text: @button_name, style_class: 'menu-application-button-label')
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @icon = file.createIcon(APPLICATION_ICON_SIZE)
    @addActor(@icon)
    @addActor(@label)
    return

  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1
      Gio.app_info_launch_default_for_uri(@file.uri, global.create_app_launch_context())
      @appsMenuButton.menu.close()
    return

  activate:(event) ->
    Gio.app_info_launch_default_for_uri(@file.uri, global.create_app_launch_context())
    @appsMenuButton.menu.close()
    return


    
    
  