class AppPopupSubMenuMenuItem
  __proto__: PopupMenu.PopupBaseMenuItem.prototype

  constructor:(args...) ->
    @_init(args...)

  _init:(text, hide_expander) ->
    PopupMenu.PopupBaseMenuItem.prototype._init.call(this)

    @actor.add_style_class_name('popup-submenu-menu-item')

    table = new St.Table(homogeneous: false, reactive: true )

    if not hide_expander
      @_triangle = new St.Icon(icon_name: "media-playback-start", icon_type: St.IconType.SYMBOLIC, style_class: 'popup-menu-icon')

      table.add(@_triangle, row: 0, col: 0, col_span: 1, x_expand: false, x_align: St.Align.START)

      @label = new St.Label(text: text)
      @label.set_margin_left(6.0)
      table.add(@label, row: 0, col: 1, col_span: 1, x_align: St.Align.START)

    else 
      @label = new St.Label(text: text )
      table.add(@label, row: 0, col: 0, col_span: 1, x_align: St.Align.START)

    @actor.label_actor = @label
    @addActor(table, expand: true, span: 1, align: St.Align.START)

    @menu = new PopupMenu.PopupSubMenu(@actor, @_triangle)
    @menu.connect('open-state-changed', Lang.bind(this, @_subMenuOpenStateChanged))

  _subMenuOpenStateChanged:(menu, open) ->
    @actor.change_style_pseudo_class('open', open)
    return

  destroy:() ->
    @menu.destroy()
    PopupMenu.PopupBaseMenuItem.prototype.destroy.call(this)

  _onKeyPressEvent:(actor, event) ->
    symbol = event.get_key_symbol()

    if symbol is Clutter.KEY_Right
      @menu.open(true)
      @menu.actor.navigate_focus(null, Gtk.DirectionType.DOWN, false)
      return true
    else if symbol is Clutter.KEY_Left and @menu.isOpen
      @menu.close()
      return true

    return PopupMenu.PopupBaseMenuItem.prototype._onKeyPressEvent.call(this, actor, event)

  activate:(event) ->
    @menu.open(true)

  _onButtonReleaseEvent:(actor) ->
    @menu.toggle()

