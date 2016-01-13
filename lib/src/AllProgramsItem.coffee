class AllProgramsItem extends AppPopupSubMenuMenuItem
  
  constructor:(label, icon, parent) ->
    super label
    @actor.set_style_class_name ""
    @box = new St.BoxLayout(style_class: "menu-category-button")
    @parent = parent
    
    #this.removeActor(this.label);
    @label.destroy()
    
    #this.removeActor(this._triangle);
    @_triangle.destroy()
    @_triangle = new St.Label()
    @label = new St.Label(text: " " + label)
    @icon = new St.Icon(
      style_class: "popup-menu-icon"
      icon_type: St.IconType.FULLCOLOR
      icon_name: icon
      icon_size: ICON_SIZE
    )
    @box.add_actor @icon
    @box.add_actor @label
    @addActor @box
    return

  setActive: (active) =>
    if active
      @box.set_style_class_name "menu-category-button-selected"
    else
      @box.set_style_class_name "menu-category-button"
    return

  _onButtonReleaseEvent: (actor, event) =>
    @activate event  if event.get_button() is 1
    return

  activate: (event) =>
    if @parent.leftPane.get_child() is @parent.favsBox
      @parent.switchPanes "apps"
    else
      @parent.switchPanes "favs"
    return
