class CategoryButton
  __proto__: PopupMenu.PopupBaseMenuItem::
  
  constructor:(app) ->
    @_init app
    
  _init: (category) =>
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-category-button"
    label = undefined
    if category
      icon = category.get_icon()
      if icon and icon.get_names
        @icon_name = icon.get_names().toString()
      else
        @icon_name = ""
      label = category.get_name()
    else
      label = _("All Applications")
    @actor._delegate = this
    @label = new St.Label(
      text: label
      style_class: "menu-category-button-label"
    )
    if category and @icon_name
      @icon = new St.Icon(
        icon_name: @icon_name
        icon_size: CATEGORY_ICON_SIZE
        icon_type: St.IconType.FULLCOLOR
      )
      @addActor @icon
    @addActor @label
    return
