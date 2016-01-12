class PlaceButton
  __proto__: PopupMenu.PopupBaseMenuItem::
  
  constructor:(appsMenuButton, place, button_name) ->
    @_init(appsMenuButton, place, button_name)

  _init:(appsMenuButton, place, button_name) ->
    PopupMenu.PopupBaseMenuItem::_init.call(this, hover: false)
    @appsMenuButton = appsMenuButton
    @place = place
    @button_name = button_name
    @actor.set_style_class_name('menu-application-button')
    @actor._delegate = this
    @label = new St.Label(text: @button_name, style_class: 'menu-application-button-label')
    @icon = place.iconFactory(APPLICATION_ICON_SIZE)
    @addActor(@icon)
    @addActor(@label)
    return

  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1
      @place.launch()
      @appsMenuButton.menu.close()
    return

  activate:(event) ->
    @place.launch()
    @appsMenuButton.menu.close()
    return
