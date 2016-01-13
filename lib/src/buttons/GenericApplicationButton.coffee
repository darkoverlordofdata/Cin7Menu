class GenericApplicationButton
  __proto__: PopupMenu.PopupSubMenuMenuItem::

  constructor: (appsMenuButton, app) ->
    @_init appsMenuButton, app
    
  _init: (appsMenuButton, app, withMenu) ->
    @app = app
    @appsMenuButton = appsMenuButton
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @withMenu = withMenu
    if @withMenu
      @menu = new PopupMenu.PopupSubMenu(@actor)
      @menu.actor.set_style_class_name "menu-context-menu"
      @menu.connect "open-state-changed", Lang.bind(this, @_subMenuOpenStateChanged)
    return

  _onButtonReleaseEvent: (actor, event) ->
    @activate event  if event.get_button() is 1
    if event.get_button() is 3
      @appsMenuButton.closeApplicationsContextMenus @app, true  if @withMenu and not @menu.isOpen
      @toggleMenu()
    true

  activate: (event) ->
    @app.open_new_window -1
    @appsMenuButton.menu.close()
    return

  closeMenu: ->
    @menu.close()  if @withMenu
    return

  toggleMenu: ->
    return  unless @withMenu
    unless @menu.isOpen
      children = @menu.box.get_children()
      for i of children
        @menu.box.remove_actor children[i]
      menuItem = undefined
      menuItem = new ApplicationContextMenuItem(this, _("Add to panel"), "add_to_panel")
      @menu.addMenuItem menuItem
      if USER_DESKTOP_PATH
        menuItem = new ApplicationContextMenuItem(this, _("Add to desktop"), "add_to_desktop")
        @menu.addMenuItem menuItem
      if AppFavorites.getAppFavorites().isFavorite(@app.get_id())
        menuItem = new ApplicationContextMenuItem(this, _("Remove from favorites"), "remove_from_favorites")
        @menu.addMenuItem menuItem
      else
        menuItem = new ApplicationContextMenuItem(this, _("Add to favorites"), "add_to_favorites")
        @menu.addMenuItem menuItem
    @menu.toggle()
    return

  _subMenuOpenStateChanged: ->
    @appsMenuButton._scrollToButton @menu  if @menu.isOpen
    return
