# ApplicationButton = (appsMenuButton, app) ->
#   @_init appsMenuButton, app
#   return
# ApplicationButton:: =
#   __proto__: GenericApplicationButton::
#   _init: (appsMenuButton, app) ->

class ApplicationButton extends GenericApplicationButton

  constructor: (appsMenuButton, app) ->
    #GenericApplicationButton::_init.call this, appsMenuButton, app, true
    @_init appsMenuButton, app, true
    @category = new Array()
    @actor.set_style_class_name "menu-application-button"
    @icon = @app.create_icon_texture(APPLICATION_ICON_SIZE)
    @addActor @icon
    @name = @app.get_name()
    @label = new St.Label(
      text: @name
      style_class: "menu-application-button-label"
    )
    @addActor @label
    @_draggable = DND.makeDraggable(@actor)
    @isDraggableApp = true
    return

  get_app_id: ->
    @app.get_id()

  getDragActor: ->
    favorites = AppFavorites.getAppFavorites().getFavorites()
    nbFavorites = favorites.length
    monitorHeight = Main.layoutManager.primaryMonitor.height
    real_size = (0.7 * monitorHeight) / nbFavorites
    icon_size = 0.6 * real_size
    icon_size = MAX_FAV_ICON_SIZE  if icon_size > MAX_FAV_ICON_SIZE
    @app.create_icon_texture icon_size

  
  # Returns the original actor that should align with the actor
  # we show as the item is being dragged.
  getDragActorSource: ->
    @actor
