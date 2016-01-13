# ShutdownMenu = (parent, hoverIcon) ->
#   @_init parent, hoverIcon
#   return
# ShutdownMenu:: =
#   __proto__: AppPopupSubMenuMenuItem::
#   _init: (parent, hoverIcon) ->
  
class ShutdownMenu extends AppPopupSubMenuMenuItem

  constructor: (parent, hoverIcon) ->
    label = ""
    @hoverIcon = hoverIcon
    @parent = parent
    #AppPopupSubMenuMenuItem::_init.call this, label
    @_init label
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

  setActive: (active) ->
    if active
      @actor.set_style_class_name "menu-category-button-selected"
      @hoverIcon._refresh "system-log-out"
    else
      @actor.set_style_class_name "menu-category-button"
    return

  _onButtonReleaseEvent: (actor, event) ->
    @menu.toggle()  if event.get_button() is 1
    return
