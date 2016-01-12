class TextBoxItem
  __proto__: AppPopupSubMenuMenuItem::
  
  constructor:(label, icon, func, parent, hoverIcon) ->
    @_init(label, icon, func, parent, hoverIcon)
    
  _init:(label, icon, func, parent, hoverIcon) ->
    @parent = parent
    @hoverIcon = hoverIcon
    @icon = icon
    @func = func
    @active = false
    AppPopupSubMenuMenuItem::_init.call(this, label)

    @actor.set_style_class_name('menu-category-button')
    @actor.add_style_class_name('menu-text-item-button')
    @actor.connect('leave-event', Lang.bind(this, @_onLeaveEvent))
    #@removeActor(@label)
    @label.destroy()
    #@removeActor(@_triangle)

    @_triangle.destroy()
    @_triangle = new St.Label()
    @label_text = label

    @label_icon = new St.Icon(icon_name: @icon, icon_size: 18, icon_type: St.IconType.FULLCOLOR)
    @addActor(@label_icon)
    @label = new St.Label(text: @label_text, style_class: 'menu-category-button-label')
    @addActor(@label)
    return

  _update:(quicklinkOptions) ->
    @removeActor(@label_icon)
    @removeActor(@label)

    if quicklinkOptions is 'both' or quicklinkOptions is 'icons'
      @name_icon = new St.Icon(icon_name: @icon, icon_size: (if quicklinkOptions is 'icons' then 26 else 18), icon_type: St.IconType.FULLCOLOR,)

      iconFileName = @icon
      iconFile = Gio.file_new_for_path(iconFileName)

      if iconFile.query_exists(null)
        icon = new Gio.FileIcon(file: iconFile)
      else
        icon = new Gio.ThemedIcon(name: @icon)

      @label_icon.set_gicon (icon)
      @label_icon.set_icon_size(if quicklinkOptions is 'icons' then 26 else 18)

      if not iconFile.query_exists(null)
        @label_icon = @name_icon

      @addActor(@label_icon)

    if quicklinkOptions is 'both' or quicklinkOptions is 'labels'
      @label = new St.Label(text: @label_text, style_class: 'menu-category-button-label')
      @addActor(@label)


  _onLeaveEvent:() ->
    @hoverIcon.showUser = true
    Tweener.addTween(this,
      time: 1,
      onComplete: ->
        if(not @active) then @hoverIcon._onUserChanged()
        return
    )
    return

  setActive:(active) ->
    if active
      @hoverIcon.showUser = false
      @actor.set_style_class_name('menu-category-button-selected')
      if @parent.quicklinkOptions isnt 'icons'
        @hoverIcon._refresh(@icon)
      else
        @actor.set_style_class_name('menu-category-button')
    return


  _onButtonReleaseEvent:(actor, event) ->
    if event.get_button() is 1 then this.activate(event)
    return


  activate:(event) ->
    eval(@func)
    @parent.close()
