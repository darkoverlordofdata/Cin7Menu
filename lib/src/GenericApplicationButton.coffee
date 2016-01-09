class GenericApplicationButton
  __proto__: PopupMenu.PopupSubMenuMenuItem.prototype
  
  constructor:(appsMenuButton, app) ->
    @_init(appsMenuButton, app)
    
  _init:(appsMenuButton, app) ->
    @app = app
    @appsMenuButton = appsMenuButton
    PopupMenu.PopupBaseMenuItem.prototype._init.call(this, hover: false)

    @withMenu = withMenu
    if @withMenu
      @menu = new PopupMenu.PopupSubMenu(@actor)
      @menu.actor.set_style_class_name('menu-context-menu')
      @menu.connect('open-state-changed', Lang.bind(this, @_subMenuOpenStateChanged))

  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1
      @activate(event)

    if event.get_button() is 3
      if @withMenu and not @menu.isOpen
        @appsMenuButton.closeApplicationsContextMenus(@app, true)
      @toggleMenu()

    true

  activate:(event) ->
    @app.open_new_window(-1)
    @appsMenuButton.menu.close()


  closeMenu:() ->
    if @withMenu then @menu.close()


  toggleMenu:() ->
    if (!@withMenu) then return

    if (!@menu.isOpen)
      children = @menu.box.get_children()
      for child in children
        @menu.box.remove_actor(child)

      menuItem = new ApplicationContextMenuItem(this, _("Add to panel"), "add_to_panel")
      @menu.addMenuItem(menuItem)
      if USER_DESKTOP_PATH
        menuItem = new ApplicationContextMenuItem(this, _("Add to desktop"), "add_to_desktop")
        @menu.addMenuItem(menuItem)

      if AppFavorites.getAppFavorites().isFavorite(@app.get_id())
        menuItem = new ApplicationContextMenuItem(this, _("Remove from favorites"), "remove_from_favorites")
        @menu.addMenuItem(menuItem)
      else
        menuItem = new ApplicationContextMenuItem(this, _("Add to favorites"), "add_to_favorites")
        @menu.addMenuItem(menuItem)

    @menu.toggle()
    return

  _subMenuOpenStateChanged:() ->
    if @menu.isOpen then @appsMenuButton._scrollToButton(@menu)