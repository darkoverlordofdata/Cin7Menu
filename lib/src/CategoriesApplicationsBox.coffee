class CategoriesApplicationsBox
  
  constructor:() ->
    @actor = new St.BoxLayout()
    @actor._delegate = this


  acceptDrop:(source, actor, x, y, time) ->
    if source instanceof FavoritesButton
      source.actor.destroy()
      actor.destroy()
      AppFavorites.getAppFavorites().removeFavorite(source.app.get_id())
      return true
    return false
