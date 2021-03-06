class ShutdownMenu 
  __proto__: AppPopupSubMenuMenuItem::

  constructor: (@parent, @hoverIcon) ->
    @_init(@parent, @hoverIcon)
    
  _init: (@parent, @hoverIcon) =>
    AppPopupSubMenuMenuItem::_init.call this, ""
    @actor.set_style_class_name "menu-category-button"
    
    #this.removeActor(this.label);
    @label.destroy()
    
    #this.removeActor(this._triangle);
    @_triangle.destroy()
    @_triangle = new St.Label()
    @icon = new St.Icon(
      style_class: "popup-menu-icon"
      icon_type: St.IconType.FULLCOLOR
      icon_name: "forward"
      icon_size: ICON_SIZE
    )
    @addActor @icon
    @menu = new PopupMenu.PopupSubMenu(@actor)
    @menu.actor.remove_style_class_name "popup-sub-menu"
    menuItem = undefined
    menuItem = new ShutdownContextMenuItem(@parent, @menu, _("Logout"), "logout")
    @menu.addMenuItem menuItem
    menuItem = new ShutdownContextMenuItem(@parent, @menu, _("Lock Screen"), "lock")
    @menu.addMenuItem menuItem
    return

  setActive: (active) =>
    if active
      @actor.set_style_class_name "menu-category-button-selected"
      @hoverIcon._refresh "system-log-out"
    else
      @actor.set_style_class_name "menu-category-button"
    return

  _onButtonReleaseEvent: (actor, event) =>
    @menu.toggle()  if event.get_button() is 1
    return
