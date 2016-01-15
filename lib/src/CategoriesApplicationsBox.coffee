class CategoriesApplicationsBox

  constructor: ->
    @_init()
    
  _init: =>    
    @actor = new St.BoxLayout()
    @actor._delegate = this
    return

  acceptDrop: (source, actor, x, y, time) =>
    if source instanceof FavoritesButton
      source.actor.destroy()
      actor.destroy()
      AppFavorites.getAppFavorites().removeFavorite source.app.get_id()
      return true
    false
