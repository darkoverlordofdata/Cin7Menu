class AllProgramsItem
  __proto__: AppPopupSubMenuMenuItem.prototype

  constructor:(label, icon, parent) ->
    @_init(label, icon, parent)

  _init(label, icon, parent) ->
    AppPopupSubMenuMenuItem.prototype._init.call(this, label)

    @actor.set_style_class_name('')
    @box = new St.BoxLayout(style_class: 'menu-category-button')
    @parent = parent
    #@removeActor(@label)
    @label.destroy()
    #@removeActor(@_triangle)
    @_triangle.destroy()
    @_triangle = new St.Label()
    @label = new St.Label(text: " " + label)
    @icon = new St.Icon(
      style_class: 'popup-menu-icon'
      icon_type: St.IconType.FULLCOLOR
      icon_name: icon
      icon_size: ICON_SIZE
    )
    @box.add_actor(@icon)
    @box.add_actor(@label)
    @addActor(@box)

  setActive: (active) ->
    if active then this.box.set_style_class_name('menu-category-button-selected')
    else this.box.set_style_class_name('menu-category-button')

  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1
      this.activate(event)

  activate:(event) ->
    if this.parent.leftPane.get_child() is this.parent.favsBox then this.parent.switchPanes("apps")
    else this.parent.switchPanes("favs")



