class PlaceCategoryButton
  __proto__: base = PopupMenu.PopupBaseMenuItem.prototype

  constructor:(app) ->
    @_init(app)
    
  _init:(category) ->
    base._init.call(this, hover: false)
    @actor.set_style_class_name('menu-category-button')
    @actor._delegate = this
    @label = new St.Label(text: _("Places"), style_class: 'menu-category-button-label')
    @icon = new St.Icon(icon_name: "folder", icon_size: CATEGORY_ICON_SIZE, icon_type: St.IconType.FULLCOLOR)
    @addActor(@icon)
    @addActor(@label)
    return    
    