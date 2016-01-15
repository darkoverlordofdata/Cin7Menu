FavoritesButton = (appsMenuButton, app, nbFavorites, iconSize) ->
  @_init appsMenuButton, app, nbFavorites, iconSize
  return
FavoritesButton:: =
  __proto__: GenericApplicationButton::
  _init: (appsMenuButton, app, nbFavorites, iconSize) ->
    GenericApplicationButton::_init.call this, appsMenuButton, app, true
    monitorHeight = Main.layoutManager.primaryMonitor.height
    real_size = (0.7 * monitorHeight) / nbFavorites
    icon_size = iconSize #0.6*real_size;
    icon_size = MAX_FAV_ICON_SIZE  if icon_size > MAX_FAV_ICON_SIZE
    @actor.style = "padding-top: " + (icon_size / 3) + "px;padding-bottom: " + (icon_size / 3) + "px; margin:auto;"
    @actor.add_style_class_name "menu-favorites-button"
    @addActor app.create_icon_texture(icon_size)
    @label = new St.Label(
      text: @app.get_name()
      style_class: "menu-application-button-label"
    )
    @addActor @label
    @_draggable = DND.makeDraggable(@actor)
    @isDraggableApp = true
    return

  get_app_id: ->
    @app.get_id()

  getDragActor: ->
    new Clutter.Clone(source: @actor)

  
  # Returns the original actor that should align with the actor
  # we show as the item is being dragged.
  getDragActorSource: ->
    @actor
