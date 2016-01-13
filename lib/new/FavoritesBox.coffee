FavoritesBox = ->
  @_init()
  return
FavoritesBox:: =
  _init: ->
    @actor = new St.BoxLayout(vertical: true)
    @actor._delegate = this
    @_dragPlaceholder = null
    @_dragPlaceholderPos = -1
    @_animatingPlaceholdersCount = 0
    return

  _clearDragPlaceholder: ->
    if @_dragPlaceholder
      @_dragPlaceholder.animateOutAndDestroy()
      @_dragPlaceholder = null
      @_dragPlaceholderPos = -1
    return

  handleDragOver: (source, actor, x, y, time) ->
    app = source.app
    
    # Don't allow favoriting of transient apps
    return DND.DragMotionResult.NO_DROP  if not app? or app.is_window_backed() or ((source not instanceof FavoritesButton) and app.get_id() of AppFavorites.getAppFavorites().getFavoriteMap())
    favorites = AppFavorites.getAppFavorites().getFavorites()
    numFavorites = favorites.length
    favPos = favorites.indexOf(app)
    children = @actor.get_children()
    numChildren = children.length
    boxHeight = @actor.height
    
    # Keep the placeholder out of the index calculation; assuming that
    # the remove target has the same size as "normal" items, we don't
    # need to do the same adjustment there.
    if @_dragPlaceholder
      boxHeight -= @_dragPlaceholder.actor.height
      numChildren--
    pos = Math.round(y * numFavorites / boxHeight)
    if pos isnt @_dragPlaceholderPos and pos <= numFavorites
      if @_animatingPlaceholdersCount > 0
        appChildren = children.filter((actor) ->
          actor._delegate instanceof FavoritesButton
        )
        @_dragPlaceholderPos = children.indexOf(appChildren[pos])
      else
        @_dragPlaceholderPos = pos
      
      # Don't allow positioning before or after self
      if favPos isnt -1 and (pos is favPos or pos is favPos + 1)
        if @_dragPlaceholder
          @_dragPlaceholder.animateOutAndDestroy()
          @_animatingPlaceholdersCount++
          @_dragPlaceholder.actor.connect "destroy", Lang.bind(this, ->
            @_animatingPlaceholdersCount--
            return
          )
        @_dragPlaceholder = null
        return DND.DragMotionResult.CONTINUE
      
      # If the placeholder already exists, we just move
      # it, but if we are adding it, expand its size in
      # an animation
      fadeIn = undefined
      if @_dragPlaceholder
        @_dragPlaceholder.actor.destroy()
        fadeIn = false
      else
        fadeIn = true
      @_dragPlaceholder = new DND.GenericDragPlaceholderItem()
      @_dragPlaceholder.child.set_width source.actor.height
      @_dragPlaceholder.child.set_height source.actor.height
      @actor.insert_actor @_dragPlaceholder.actor, @_dragPlaceholderPos
      @_dragPlaceholder.animateIn()  if fadeIn
    srcIsFavorite = (favPos isnt -1)
    return DND.DragMotionResult.MOVE_DROP  if srcIsFavorite
    DND.DragMotionResult.COPY_DROP

  
  # Draggable target interface
  acceptDrop: (source, actor, x, y, time) ->
    app = source.app
    
    # Don't allow favoriting of transient apps
    return false  if not app? or app.is_window_backed()
    id = app.get_id()
    favorites = AppFavorites.getAppFavorites().getFavoriteMap()
    srcIsFavorite = (id of favorites)
    favPos = 0
    children = @actor.get_children()
    i = 0

    while i < @_dragPlaceholderPos
      continue  if @_dragPlaceholder and children[i] is @_dragPlaceholder.actor
      continue  unless children[i]._delegate instanceof FavoritesButton
      childId = children[i]._delegate.app.get_id()
      continue  if childId is id
      favPos++  if childId of favorites
      i++
    Meta.later_add Meta.LaterType.BEFORE_REDRAW, Lang.bind(this, ->
      appFavorites = AppFavorites.getAppFavorites()
      if srcIsFavorite
        appFavorites.moveFavoriteToPos id, favPos
      else
        appFavorites.addFavoriteAtPos id, favPos
      false
    )
    true
