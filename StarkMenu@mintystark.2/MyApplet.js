function MyApplet(orientation, panel_height, instance_id) {
    this._init(orientation, panel_height, instance_id);
}

MyApplet.prototype = {
    __proto__: Applet.TextIconApplet.prototype,

    _init: function(orientation, panel_height, instance_id) {
        Applet.TextIconApplet.prototype._init.call(this, orientation, panel_height, instance_id);

        try {
            this.set_applet_tooltip(_("Menu"));

            this.menuManager = new PopupMenu.PopupMenuManager(this);
            this.menu = new Applet.AppletPopupMenu(this, orientation);
            this.menuManager.addMenu(this.menu);

            this.actor.connect('key-press-event', Lang.bind(this, this._onSourceKeyPress));

            this.settings = new Settings.AppletSettings(this, "StarkMenu@mintystark", instance_id);

            this.settings.bindProperty(Settings.BindingDirection.IN, "show-recent", "showRecent", this._refreshPlacesAndRecent, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "show-places", "showPlaces", this._refreshPlacesAndRecent, null);

            this.settings.bindProperty(Settings.BindingDirection.IN, "activate-on-hover", "activateOnHover", this._updateActivateOnHover, null);
            this._updateActivateOnHover();

            this.menu.actor.add_style_class_name('menu-background');

            this.settings.bindProperty(Settings.BindingDirection.IN, "menu-icon", "menuIcon", this._updateIconAndLabel, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "menu-label", "menuLabel", this._updateIconAndLabel, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "all-programs-label", "allProgramsLabel", null, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "favorites-label", "favoritesLabel", null, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "shutdown-label", "shutdownLabel", null, null);
            this._updateIconAndLabel();


            this._searchInactiveIcon = new St.Icon({ style_class: 'menu-search-entry-icon',
                                               icon_name: 'edit-find',
                                               icon_type: St.IconType.SYMBOLIC });
            this._searchActiveIcon = new St.Icon({ style_class: 'menu-search-entry-icon',
                                             icon_name: 'edit-clear',
                                             icon_type: St.IconType.SYMBOLIC });
            this._searchIconClickedId = 0;
            this._applicationsButtons = new Array();
            this._favoritesButtons = new Array();
            this._placesButtons = new Array();
            this._transientButtons = new Array();
            this._recentButtons = new Array();
            this._selectedItemIndex = null;
            this._previousTreeItemIndex = null;
            this._previousSelectedActor = null;
            this._previousTreeSelectedActor = null;
            this._activeContainer = null;
            this._activeActor = null;
            this._applicationsBoxWidth = 0;
            this.menuIsOpening = false;

            this.RecentManager = new DocInfo.DocManager();

            this._display();
            this.menu.connect('open-state-changed', Lang.bind(this, this._onOpenStateChanged));
            appsys.connect('installed-changed', Lang.bind(this, this._refreshApps));
            AppFavorites.getAppFavorites().connect('changed', Lang.bind(this, this._refreshFavs));

            this.settings.bindProperty(Settings.BindingDirection.IN, "hover-delay", "hover_delay_ms", this._update_hover_delay, null);
            this._update_hover_delay();

            this.settings.bindProperty(Settings.BindingDirection.IN, "show-quicklinks", "showQuicklinks", this._updateQuickLinksView, null);
            this._updateQuickLinksView();

            this.settings.bindProperty(Settings.BindingDirection.IN, "show-quicklinks-shutdown-menu", "showQuicklinksShutdownMenu", this._updateQuickLinksShutdownView, null);
            this._updateQuickLinksShutdownView();
	    
	    /*
            global.display.connect('overlay-key', Lang.bind(this, function(){
                try{
                    this.menu.toggle();
                }
                catch(e) {
                    global.logError(e);
                }
            }));
	    */

            Main.placesManager.connect('places-updated', Lang.bind(this, this._refreshApps));
            this.RecentManager.connect('changed', Lang.bind(this, this._refreshApps));

            this._fileFolderAccessActive = false;

            this._pathCompleter = new Gio.FilenameCompleter();
            this._pathCompleter.set_dirs_only(false);
            this.lastAcResults = new Array();

            this.settings.bindProperty(Settings.BindingDirection.IN, "search-filesystem", "searchFilesystem", null, null);

            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-0", "quicklink_0", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-1", "quicklink_1", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-2", "quicklink_2", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-3", "quicklink_3", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-4", "quicklink_4", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-5", "quicklink_5", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-6", "quicklink_6", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-7", "quicklink_7", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-8", "quicklink_8", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-9", "quicklink_9", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-10", "quicklink_10", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-11", "quicklink_11", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-12", "quicklink_12", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-13", "quicklink_13", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-14", "quicklink_14", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-15", "quicklink_15", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-16", "quicklink_16", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-17", "quicklink_17", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-18", "quicklink_18", this._updateQuickLinks, null);
            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-19", "quicklink_19", this._updateQuickLinks, null);

            this.settings.bindProperty(Settings.BindingDirection.IN, "quicklink-options", "quicklinkOptions", this._updateQuickLinks, null);
            this._updateQuickLinks();


        }
        catch (e) {
            global.logError(e);
        }
    },

    openMenu: function() {
        this.menu.open(true);
    },

    _updateActivateOnHover: function() {
        if (this._openMenuId) {
            this.actor.disconnect(this._openMenuId);
            this._openMenuId = 0;
        }
        if (this.activateOnHover) {
            this._openMenuId = this.actor.connect('enter-event', Lang.bind(this, this.openMenu));
        }
    },

    _updateQuickLinksView : function(){
        this.menu.showQuicklinks = this.showQuicklinks;
        if(this.menu.showQuicklinks)
        {
            this.rightButtonsBox.actor.show();
        }
        else
        {
            this.rightButtonsBox.actor.hide();
        }
    },

    _updateQuickLinksShutdownView : function(){
        this.menu.showQuicklinksShutdownMenu = this.showQuicklinksShutdownMenu;
        if(this.menu.showQuicklinksShutdownMenu)
        {
            this.rightButtonsBox.shutdown.actor.show();
            this.rightButtonsBox.shutdownMenu.actor.show();

            if(this.quicklinkOptions != 'icons')
            {
                this.rightButtonsBox.shutDownMenuBox.set_style('min-height: 82px');
            }
            else
            {
                this.rightButtonsBox.shutDownIconBox.show();
            }
        }
        else
        {
            this.rightButtonsBox.shutdown.actor.hide();
            this.rightButtonsBox.shutdownMenu.actor.hide();
            this.rightButtonsBox.shutDownIconBox.hide();
            this.rightButtonsBox.shutDownMenuBox.set_style('min-height: 1px');
        }
        this.favsBox.style = "min-height: "+(this.rightButtonsBox.actor.get_height()-100)+"px;min-width: 235px;";
    },

    _updateQuickLinks: function() {
        this.menu.quicklinks = [];
        this.menu.quicklinks[0] = this.quicklink_0;
        this.menu.quicklinks[1] = this.quicklink_1;
        this.menu.quicklinks[2] = this.quicklink_2;
        this.menu.quicklinks[3] = this.quicklink_3;
        this.menu.quicklinks[4] = this.quicklink_4;
        this.menu.quicklinks[5] = this.quicklink_5;
        this.menu.quicklinks[6] = this.quicklink_6;
        this.menu.quicklinks[7] = this.quicklink_7;
        this.menu.quicklinks[8] = this.quicklink_8;
        this.menu.quicklinks[9] = this.quicklink_9;
        this.menu.quicklinks[10] = this.quicklink_10;
        this.menu.quicklinks[11] = this.quicklink_11;
        this.menu.quicklinks[12] = this.quicklink_12;
        this.menu.quicklinks[13] = this.quicklink_13;
        this.menu.quicklinks[14] = this.quicklink_14;
        this.menu.quicklinks[15] = this.quicklink_15;
        this.menu.quicklinks[16] = this.quicklink_16;
        this.menu.quicklinks[17] = this.quicklink_17;
        this.menu.quicklinks[18] = this.quicklink_18;
        this.menu.quicklinks[19] = this.quicklink_19;

        this.menu.quicklinkOptions = this.quicklinkOptions;
        this.rightButtonsBox.addItems();
        this.rightButtonsBox._update_quicklinks(this.quicklinkOptions);

        this._updateQuickLinksShutdownView();

        this.favsBox.style = "min-height: "+(this.rightButtonsBox.actor.get_height()-100)+"px;min-width: 235px;";

    },

    _update_hover_delay: function() {
        this.hover_delay = this.hover_delay_ms / 1000
    },

    on_orientation_changed: function (orientation) {
        this.menu.destroy();
        this.menu = new Applet.AppletPopupMenu(this, orientation);
        this.menuManager.addMenu(this.menu);

        this.menu.actor.add_style_class_name('menu-background');
        this.menu.connect('open-state-changed', Lang.bind(this, this._onOpenStateChanged));
        this._display();
        this._updateQuickLinksShutdownView();
        this._updateQuickLinks();
    },

    _launch_editor: function() {
        Util.spawnCommandLine("cinnamon-menu-editor");
    },

    on_applet_clicked: function(event) {
        this.menu.toggle();
    },

    _onSourceKeyPress: function(actor, event) {
        var symbol = event.get_key_symbol();

        if (symbol == Clutter.KEY_space || symbol == Clutter.KEY_Return) {
            this.menu.toggle();
            return true;
        } else if (symbol == Clutter.KEY_Escape && this.menu.isOpen) {
            this.menu.close();
            return true;
        } else if (symbol == Clutter.KEY_Down) {
            if (!this.menu.isOpen)
                this.menu.toggle();
            this.menu.actor.navigate_focus(this.actor, Gtk.DirectionType.DOWN, false);
            return true;
        } else
            return false;
    },

    _onOpenStateChanged: function(menu, open) {
        if (open) {
            this.menuIsOpening = true;
            this.actor.add_style_pseudo_class('active');
            this.switchPanes("favs");
        this._appletStyles();
            global.stage.set_key_focus(this.searchEntry);
            this._selectedItemIndex = null;
            this._activeContainer = null;
            this._activeActor = null;
            var monitorHeight = Main.layoutManager.primaryMonitor.height;
            this._select_category(null, this._allAppsCategoryButton);
    } else {
            this.actor.remove_style_pseudo_class('active');
            if (this.searchActive) {
        this.resetSearch();
        }
            this.selectedAppTitle.set_text("");
            this.selectedAppDescription.set_text("");
            this._previousTreeItemIndex = null;
            this._previousTreeSelectedActor = null;
            this._previousSelectedActor = null;
            this.closeApplicationsContextMenus(null, false);
            this._clearAllSelections();
        }
    },

    destroy: function() {
        this.actor._delegate = null;
        this.menu.destroy();
        this.actor.destroy();
        this.emit('destroy');
    },

    _updateIconAndLabel: function(){

        this.set_applet_label(this.menuLabel);

        try {
           this.set_applet_icon_path(this.menuIcon);
        } catch(e) {
           global.logWarning("Could not load icon file \""+this.menuIcon+"\" for menu button");
        }
    },

    _onMenuKeyPress: function(actor, event) {

        var symbol = event.get_key_symbol();
        var item_actor;
        var index = 0;
        this.appBoxIter.reloadVisible();
        this.catBoxIter.reloadVisible();

        if (symbol==Clutter.KEY_Super_L && this.menu.isOpen)
        {
            this.menu.close();
            return true;
        }
        var index = this._selectedItemIndex;

        if (this._activeContainer === null && symbol == Clutter.KEY_Up)
        {
            this._activeContainer = this.applicationsBox;
            item_actor = this.appBoxIter.getLastVisible();
            index = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
        }
        else if (this._activeContainer === null && symbol == Clutter.KEY_Down)
        {
            this._activeContainer = this.applicationsBox;
            item_actor = this.appBoxIter.getFirstVisible();
            index = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
        }
        else if (symbol == Clutter.KEY_Up)
        {
            if (this._activeContainer == this.applicationsBox)
            {
                this._previousSelectedActor = this.applicationsBox.get_child_at_index(index);
                item_actor = this.appBoxIter.getPrevVisible(this._previousSelectedActor);
                index = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
            }
            else
            {
                this._previousSelectedActor = this.categoriesBox.get_child_at_index(index);
                this._previousSelectedActor._delegate.isHovered = false;
                item_actor = this.catBoxIter.getPrevVisible(this._activeActor)
                index = this.catBoxIter.getAbsoluteIndexOfChild(item_actor);
            }
        }
        else if (symbol == Clutter.KEY_Down)
        {
            if (this._activeContainer == this.applicationsBox)
            {
                this._previousSelectedActor = this.applicationsBox.get_child_at_index(index);
                item_actor = this.appBoxIter.getNextVisible(this._previousSelectedActor);
                index = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
            }
            else
            {
                this._previousSelectedActor = this.categoriesBox.get_child_at_index(index);
                this._previousSelectedActor._delegate.isHovered = false;
                item_actor = this.catBoxIter.getNextVisible(this._activeActor)
                index = this.catBoxIter.getAbsoluteIndexOfChild(item_actor);
            }
        }
        else if (symbol == Clutter.KEY_Right && (this._activeContainer !== this.applicationsBox))
        {
            // Jump from Categories to Appications
            item_actor = this.appBoxIter.getFirstVisible();
            index = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
        }
        else if (symbol == Clutter.KEY_Left && this._activeContainer === this.applicationsBox && !this.searchActive)
        {
            // Jump from Appications to Categories
            this._previousSelectedActor = this.applicationsBox.get_child_at_index(index);
            item_actor = (this._previousTreeSelectedActor != null) ? this._previousTreeSelectedActor : this.catBoxIter.getFirstVisible();
            index = this.catBoxIter.getAbsoluteIndexOfChild(item_actor);
        }
        else if (this._activeContainer === this.applicationsBox && (symbol == Clutter.KEY_Return || symbol == Clutter.KP_Enter))
        {
            item_actor = this.applicationsBox.get_child_at_index(this._selectedItemIndex);
            item_actor._delegate.activate();
            return true;
        }
        else if (this.searchFilesystem && (this._fileFolderAccessActive || symbol == Clutter.slash))
        {
            if (symbol == Clutter.Return || symbol == Clutter.KP_Enter)
            {
                if (this._run(this.searchEntry.get_text()))
                {
                    this.menu.close();
                }
                return true;
            }
            if (symbol == Clutter.Escape)
            {
                this.searchEntry.set_text('');
                this._fileFolderAccessActive = false;
            }
            if (symbol == Clutter.slash)
            {
                // Need preload data before get completion. GFilenameCompleter load content of parent directory.
                // Parent directory for /usr/include/ is /usr/. So need to add fake name('a').
                var text = this.searchEntry.get_text().concat('/a');
                var prefix;
                if (text.lastIndexOf(' ') == -1)
                    prefix = text;
                else
                    prefix = text.substr(text.lastIndexOf(' ') + 1);
                this._getCompletion(prefix);

                return false;
            }
            if (symbol == Clutter.Tab)
            {
                var text = actor.get_text();
                var prefix;
                if (text.lastIndexOf(' ') == -1)
                {
                    prefix = text;
                }
                else
                {
                    prefix = text.substr(text.lastIndexOf(' ') + 1);
                }
                var postfix = this._getCompletion(prefix);

                if (postfix != null && postfix.length > 0)
                {
                    actor.insert_text(postfix, -1);
                    actor.set_cursor_position(text.length + postfix.length);
                    if (postfix[postfix.length - 1] == '/')
                        this._getCompletion(text + postfix + 'a');
                }

                return true;
            }
            return false;

        }
        else
        {
            return false;
        }

        this._selectedItemIndex = index;
        if (!item_actor || item_actor === this.searchEntry)
        {
            return false;
        }
        item_actor._delegate.emit('enter-event');
        return true;
    },

    _addEnterEvent: function(button, callback) {
        var _callback = Lang.bind(this, function() {
            var parent = button.actor.get_parent();
            if (this._activeContainer !== this.applicationsBox && parent !== this._activeContainer) {
                this._previousTreeItemIndex = this._selectedItemIndex;
                this._previousTreeSelectedActor = this._activeActor;
                this._previousSelectedActor = null;
            }
            if (this._previousTreeSelectedActor && this._activeContainer !== this.categoriesBox &&
                    parent !== this._activeContainer && button !== this._previousTreeSelectedActor) {
                this._previousTreeSelectedActor.style_class = "menu-category-button";
            }
            if (parent != this._activeContainer) {
                parent._vis_iter.reloadVisible();
            }
            var _maybePreviousActor = this._activeActor;
            if (_maybePreviousActor && this._activeContainer === this.applicationsBox) {
                this._previousSelectedActor = _maybePreviousActor;
                this._clearPrevAppSelection();
            }
            if (parent === this.categoriesBox && !this.searchActive) {
                this._previousSelectedActor = _maybePreviousActor;
                this._clearPrevCatSelection();
            }
            this._activeContainer = parent;
            this._activeActor = button.actor;
            this._selectedItemIndex = this._activeContainer._vis_iter.getAbsoluteIndexOfChild(this._activeActor);
            callback();
        });
        button.connect('enter-event', _callback);
        button.actor.connect('enter-event', _callback);
    },

    _clearPrevAppSelection: function(actor) {
        if (this._previousSelectedActor && this._previousSelectedActor != actor) {
            this._previousSelectedActor.style_class = "menu-application-button";
        }
    },

    _clearPrevCatSelection: function(actor) {
        if (this._previousSelectedActor && this._previousSelectedActor != actor) {
            this._previousSelectedActor.style_class = "menu-category-button";
        }
    },

    _appletStyles: function (pane) {
        var favsWidth = (this.favsBox.get_allocation_box().x2 - this.favsBox.get_allocation_box().x1);
        var scrollWidth = this.searchBox.get_width() + this.rightButtonsBox.actor.get_width();
        this.searchEntry.style = "width:" + favsWidth + "px";
        this.appsButton.box.style = "width:" + favsWidth + "px";
        var scrollBoxHeight = (this.favsBox.get_allocation_box().y2 - this.favsBox.get_allocation_box().y1)-(this.selectedAppBox.get_allocation_box().y2 - this.selectedAppBox.get_allocation_box().y1);
        this.applicationsScrollBox.style = "width: " + ((scrollWidth) * 0.55) + "px;height: " + scrollBoxHeight + "px;";
        this.categoriesScrollBox.style = "width: " + ((scrollWidth) * 0.45) + "px;height: " + scrollBoxHeight + "px;";
    },

    _refreshApps : function() {
        this.applicationsBox.destroy_all_children();
        this._applicationsButtons = new Array();
        this._placesButtons = new Array();
        this._recentButtons = new Array();
        this._applicationsBoxWidth = 0;
        //Remove all categories
        this.categoriesBox.destroy_all_children();

        this._allAppsCategoryButton = new CategoryButton(null);
        this._addEnterEvent(this._allAppsCategoryButton, Lang.bind(this, function() {
            if (!this.searchActive) {
                this._allAppsCategoryButton.isHovered = true;
                this._allAppsCategoryButton.actor.style_class = "menu-category-button-selected";
                if (this.hover_delay > 0) {
                    Tweener.addTween(this, {
                           time: this.hover_delay,
                           onComplete: function () {
                               if (this._allAppsCategoryButton.isHovered) {
                                   this._clearPrevCatSelection(this._allAppsCategoryButton.actor);
                                   this._select_category(null, this._allAppsCategoryButton);
                               } else {
                                   this._allAppsCategoryButton.actor.style_class = "menu-category-button";
                               }
                           }
                    });
                } else {
                    this._clearPrevCatSelection(this._allAppsCategoryButton.actor);
                    this._select_category(null, this._allAppsCategoryButton);
                }
            }
         }));
         this._allAppsCategoryButton.actor.connect('leave-event', Lang.bind(this, function () {
            if (!this.searchActive) {
                this._allAppsCategoryButton.actor.style_class = "menu-category-button";
            }
            this._previousSelectedActor = this._allAppsCategoryButton.actor;
            this._allAppsCategoryButton.isHovered = false;
         }));
         this.categoriesBox.add_actor(this._allAppsCategoryButton.actor);

        var trees = [appsys.get_tree()];

        for (var i in trees) {
            var tree = trees[i];
            var root = tree.get_root_directory();

            var iter = root.iter();
            var nextType;
            while ((nextType = iter.next()) != CMenu.TreeItemType.INVALID) {
                if (nextType == CMenu.TreeItemType.DIRECTORY) {
                    var dir = iter.get_directory();
                    if (dir.get_is_nodisplay())
                        continue;
                    this.applicationsByCategory[dir.get_menu_id()] = new Array();
                    this._loadCategory(dir);
                    if (this.applicationsByCategory[dir.get_menu_id()].length>0){
                        var categoryButton = new CategoryButton(dir);
                        this._addEnterEvent(categoryButton, Lang.bind(this, function() {
                            if (!this.searchActive) {
                                categoryButton.isHovered = true;
                                categoryButton.actor.style_class = "menu-category-button-selected";
                                if (this.hover_delay > 0) {
                                    Tweener.addTween(this, {
                                            time: this.hover_delay,
                                            onComplete: function () {
                                                if (categoryButton.isHovered) {
                                                    this._clearPrevCatSelection(categoryButton.actor);
                                                    this._select_category(dir, categoryButton);
                                                } else {
                                                    categoryButton.actor.style_class = "menu-category-button";
                                                }
                                            }
                                    });
                                } else {
                                    this._clearPrevCatSelection(categoryButton.actor);
                                    this._select_category(dir, categoryButton);
                                }
                            }
                        }));
                      categoryButton.actor.connect('leave-event', Lang.bind(this, function () {
                            if (!this.searchActive) {
                                categoryButton.actor.style_class = "menu-category-button";
                            }
                            this._previousSelectedActor = categoryButton.actor;
                            categoryButton.isHovered = false;
                      }));
                      this.categoriesBox.add_actor(categoryButton.actor);
                    }
                }
            }
        }
        // Sort apps and add to applicationsBox
        this._applicationsButtons.sort(function(a, b) {
            var sr = a.app.get_name().toLowerCase() > b.app.get_name().toLowerCase();
            return sr;
        });

        for (var i = 0; i < this._applicationsButtons.length; i++) {
            this.applicationsBox.add_actor(this._applicationsButtons[i].actor);
            this._applicationsButtons[i].actor.realize();
            this.applicationsBox.add_actor(this._applicationsButtons[i].menu.actor);
        }

        // Now generate Places category and places buttons and add to the list
        if (this.showPlaces) {
            this.placesButton = new PlaceCategoryButton();
            this._addEnterEvent(this.placesButton, Lang.bind(this, function() {
                if (!this.searchActive) {
                    this.placesButton.isHovered = true;
                    this.placesButton.actor.style_class = "menu-category-button-selected";
                    Tweener.addTween(this, {
                        time: this.hover_delay,
                        onComplete: function () {
                            if (this.placesButton.isHovered) {
                                this._clearPrevCatSelection(this.placesButton);
                                this._displayButtons(null, -1);
                            }
                        }
                    });
                }
                this._scrollToCategoryButton(this.placesButton);
            }));
            this.placesButton.actor.connect('leave-event', Lang.bind(this, function () {
                if (!this.searchActive) {
                    this.placesButton.actor.style_class = "menu-category-button";
                }
                this._previousSelectedActor = this.placesButton.actor;
                this.placesButton.isHovered = false;
            }));
            this.categoriesBox.add_actor(this.placesButton.actor);

            var bookmarks = this._listBookmarks();
            var devices = this._listDevices();
            var places = bookmarks.concat(devices);
            for (var i = 0; i < places.length; i++) {
                var place = places[i];
                var button = new PlaceButton(this, place, place.name);
                this._addEnterEvent(button, Lang.bind(this, function() {
                        this._clearPrevAppSelection(button.actor);
                        button.actor.style_class = "menu-application-button-selected";
                        this._scrollToButton(button);
                        this.selectedAppDescription.set_text(button.place.id.slice(16));
                        }));
                button.actor.connect('leave-event', Lang.bind(this, function() {
                            button.actor.style_class = "menu-application-button";
                            this._previousSelectedActor = button.actor;
                            this.selectedAppDescription.set_text("");
                            }));
                this._placesButtons.push(button);
                this.applicationsBox.add_actor(button.actor);
            }
        }
        // Now generate recent category and recent files buttons and add to the list
        if (this.showRecent) {
            this.recentButton = new RecentCategoryButton();
            this._addEnterEvent(this.recentButton, Lang.bind(this, function() {
                if (!this.searchActive) {
                    this.recentButton.isHovered = true;
                    this.recentButton.actor.style_class = "menu-category-button-selected";
                    Tweener.addTween(this, {
                        time: this.hover_delay,
                        onComplete: function () {
                            if (this.recentButton.isHovered) {
                                this._clearPrevCatSelection(this.recentButton.actor);
                                this._displayButtons(null, null, -1);
                            }
                        }
                    });
                }
                this._scrollToCategoryButton(this.recentButton);
            }));
            this.recentButton.actor.connect('leave-event', Lang.bind(this, function () {
                if (!this.searchActive) {
                    this.recentButton.actor.style_class = "menu-category-button";
                }
                this._previousSelectedActor = this.recentButton.actor;
                this.recentButton.isHovered = false;
            }));
            this.categoriesBox.add_actor(this.recentButton.actor);

            for (var id = 0; id < MAX_RECENT_FILES && id < this.RecentManager._infosByTimestamp.length; id++) {
                var button = new RecentButton(this, this.RecentManager._infosByTimestamp[id]);
                this._addEnterEvent(button, Lang.bind(this, function() {
                        this._clearPrevAppSelection(button.actor);
                        button.actor.style_class = "menu-application-button-selected";
                        this._scrollToButton(button);
                        this.selectedAppDescription.set_text(button.file.uri.slice(7));
                        }));
                button.actor.connect('leave-event', Lang.bind(this, function() {
                        button.actor.style_class = "menu-application-button";
                        this._previousSelectedActor = button.actor;
                        this.selectedAppTitle.set_text("");
                        this.selectedAppDescription.set_text("");
                        }));
                this._recentButtons.push(button);
                this.applicationsBox.add_actor(button.actor);
            }
            if (this.RecentManager._infosByTimestamp.length > 0) {
                var button = new RecentClearButton(this);
                this._addEnterEvent(button, Lang.bind(this, function() {
                        this._clearPrevAppSelection(button.actor);
                        button.actor.style_class = "menu-application-button-selected";
                        this._scrollToButton(button);
                        }));
                button.actor.connect('leave-event', Lang.bind(this, function() {
                        button.actor.style_class = "menu-application-button";
                        this._previousSelectedActor = button.actor;
                        }));
                this._recentButtons.push(button);
                this.applicationsBox.add_actor(button.actor);
            }
        }

        this._setCategoriesButtonActive(!this.searchActive);
    },

    _refreshFavs: function () {
        //Remove all favorites
        this.favsBox.get_children().forEach(Lang.bind(this, function (child) {
            child.destroy();
        }));

        var favoritesBox = new FavoritesBox();
        this.favsBox.add_actor(favoritesBox.actor, {
            y_align: St.Align.END,
            y_fill: false
        });

        //Load favorites again
        this._favoritesButtons = new Array();
        var launchers = global.settings.get_strv('favorite-apps');
        var appSys = Cinnamon.AppSystem.get_default();
        var j = 0;
        for (var i = 0; i < launchers.length; ++i) {
            var app = appSys.lookup_app(launchers[i]);
            if (!app) app = appSys.lookup_settings_app(launchers[i]);
            if (app) {
                var button = new FavoritesButton(this, app, launchers.length, this.favorite_icon_size); // + 3 because we're adding 3 system buttons at the bottom
                this._favoritesButtons[app] = button;
                favoritesBox.actor.add_actor(button.actor, {
                    y_align: St.Align.END,
                    y_fill: false
                });
                favoritesBox.actor.add_actor(button.menu.actor, {
                    y_align: St.Align.END,
                    y_fill: false
                });
                button.actor.connect('enter-event', Lang.bind(this, function () {
                    this.selectedAppTitle.set_text(button.app.get_name());
                    if (button.app.get_description()) this.selectedAppDescription.set_text(button.app.get_description());
                    else this.selectedAppDescription.set_text("");
                }));
                button.actor.connect('leave-event', Lang.bind(this, function () {
                    this.selectedAppTitle.set_text("");
                    this.selectedAppDescription.set_text("");
                }));
                ++j;
            }
        }
    },

    _loadCategory: function(dir, top_dir) {
        var iter = dir.iter();
        var dupe = false;
        var nextType;
        if (!top_dir) top_dir = dir;
        while ((nextType = iter.next()) != CMenu.TreeItemType.INVALID) {
            if (nextType == CMenu.TreeItemType.ENTRY) {
                var entry = iter.get_entry();
                if (!entry.get_app_info().get_nodisplay()) {
                    var app = appsys.lookup_app_by_tree_entry(entry);
                    dupe = this.find_dupe(app);
                    if (!dupe) {
                        var applicationButton = new ApplicationButton(this, app);
                        applicationButton.actor.connect('realize', Lang.bind(this, this._onApplicationButtonRealized));
                        applicationButton.actor.connect('leave-event', Lang.bind(this, this._appLeaveEvent, applicationButton));
                        this._addEnterEvent(applicationButton, Lang.bind(this, this._appEnterEvent, applicationButton));
                        this._applicationsButtons.push(applicationButton);
                        applicationButton.category.push(top_dir.get_menu_id());
                        this.applicationsByCategory[top_dir.get_menu_id()].push(app.get_name());
                    } else {
                        for (var i = 0; i < this._applicationsButtons.length; i++) {
                            if (this._applicationsButtons[i].app == app) {
                                this._applicationsButtons[i].category.push(dir.get_menu_id());
                            }
                        }
                        this.applicationsByCategory[dir.get_menu_id()].push(app.get_name());
                    }
                }
            } else if (nextType == CMenu.TreeItemType.DIRECTORY) {
                var subdir = iter.get_directory();
                this.applicationsByCategory[subdir.get_menu_id()] = new Array();
                this._loadCategory(subdir, top_dir);
            }
        }
    },

    _appLeaveEvent: function(a, b, applicationButton) {
        this._previousSelectedActor = applicationButton.actor;
        applicationButton.actor.style_class = "menu-application-button";
        this.selectedAppTitle.set_text("");
        this.selectedAppDescription.set_text("");
    },

    _appEnterEvent: function(applicationButton) {
        this.selectedAppTitle.set_text(applicationButton.app.get_name());
        if (applicationButton.app.get_description())
            this.selectedAppDescription.set_text(applicationButton.app.get_description());
        else
            this.selectedAppDescription.set_text("");
        this._clearPrevAppSelection(applicationButton.actor);
        applicationButton.actor.style_class = "menu-application-button-selected";
        this._scrollToButton(applicationButton);
    },

    find_dupe: function(app) {
        var ret = false;
        for (var i = 0; i < this._applicationsButtons.length; i++) {
            if (app == this._applicationsButtons[i].app) {
                ret = true;
                break;
            }
        }
        return ret;
    },

    _scrollToButton: function(button) {
        var current_scroll_value = this.applicationsScrollBox.get_vscroll_bar().get_adjustment().get_value();
        var box_height = this.applicationsScrollBox.get_allocation_box().y2-this.applicationsScrollBox.get_allocation_box().y1;
        var new_scroll_value = current_scroll_value;
        if (current_scroll_value > button.actor.get_allocation_box().y1-10) new_scroll_value = button.actor.get_allocation_box().y1-10;
        if (box_height+current_scroll_value < button.actor.get_allocation_box().y2+10) new_scroll_value = button.actor.get_allocation_box().y2-box_height+10;
        if (new_scroll_value!=current_scroll_value) this.applicationsScrollBox.get_vscroll_bar().get_adjustment().set_value(new_scroll_value);
    },

    _scrollToCategoryButton: function(button) {
        var current_scroll_value = this.categoriesScrollBox.get_vscroll_bar().get_adjustment().get_value();
        var box_height = this.categoriesScrollBox.get_allocation_box().y2-this.categoriesScrollBox.get_allocation_box().y1;
        var new_scroll_value = current_scroll_value;
        if (current_scroll_value > button.actor.get_allocation_box().y1-10) new_scroll_value = button.actor.get_allocation_box().y1-10;
        if (box_height+current_scroll_value < button.actor.get_allocation_box().y2+10) new_scroll_value = button.actor.get_allocation_box().y2-box_height+10;
        if (new_scroll_value!=current_scroll_value) this.categoriesScrollBox.get_vscroll_bar().get_adjustment().set_value(new_scroll_value);
    },


    _display : function() {
        this._activeContainer = null;
        this._activeActor = null;
        var section = new PopupMenu.PopupMenuSection();
        this.menu.addMenuItem(section);

        this.leftPane = new St.Bin();

        this.favsBox = new St.BoxLayout({vertical: true});
        this.favsBox.style = "min-height: 152px;min-width: 235px;";

        this.appsBox = new St.BoxLayout({vertical: true});

        this.searchBox = new St.BoxLayout({ style_class: 'menu-search-box' });
        this.searchBox.set_style("padding-right: 0px;padding-left: 0px");

        this.searchEntry = new St.Entry({ name: 'menu-search-entry',
                                     hint_text: _("Type to search..."),
                                     track_hover: true,
                                     can_focus: true });
        this.searchEntry.set_secondary_icon(this._searchInactiveIcon);
        this.searchActive = false;
        this.searchEntryText = this.searchEntry.clutter_text;
        this.searchEntryText.connect('text-changed', Lang.bind(this, this._onSearchTextChanged));
        this.searchEntryText.connect('key-press-event', Lang.bind(this, this._onMenuKeyPress));
        this._previousSearchPattern = "";

        this.selectedAppBox = new St.BoxLayout({ style_class: 'menu-selected-app-box', vertical: true });
        this.selectedAppTitle = new St.Label({ style_class: 'menu-selected-app-title', text: "" });
        this.selectedAppBox.add_actor(this.selectedAppTitle);
        this.selectedAppDescription = new St.Label({ style_class: 'menu-selected-app-description', text: "" });

        this.categoriesApplicationsBox = new CategoriesApplicationsBox();
        this.categoriesBox = new St.BoxLayout({ style_class: 'menu-categories-box', vertical: true });


        this.categoriesScrollBox = new St.ScrollView({ x_fill: true, y_fill: false, y_align: St.Align.START, style_class: 'vfade menu-applications-scrollbox' });
        this.categoriesScrollBox.set_width(192);
        this.applicationsBox = new St.BoxLayout({ style_class: 'menu-applications-box', vertical:true });
        this.applicationsScrollBox = new St.ScrollView({ x_fill: true, y_fill: false, y_align: St.Align.START, style_class: 'vfade menu-applications-scrollbox' });
        this.applicationsScrollBox.set_width(244);
        this.a11y_settings = new Gio.Settings({ schema: "org.gnome.desktop.a11y.applications" });
        this.a11y_settings.connect("changed::screen-magnifier-enabled", Lang.bind(this, this._updateVFade));
        this._updateVFade();

        this.settings.bindProperty(Settings.BindingDirection.IN, "enable-autoscroll", "autoscroll_enabled", this._update_autoscroll, null);
        this._update_autoscroll();

        this.settings.bindProperty(Settings.BindingDirection.IN, "favorite-icon-size", "favorite_icon_size", this._refreshFavs, null);

        var vscroll = this.applicationsScrollBox.get_vscroll_bar();
        vscroll.connect('scroll-start',
                        Lang.bind(this, function() {
                                      this.menu.passEvents = true;
                                  }));
        vscroll.connect('scroll-stop',
                        Lang.bind(this, function() {
                                      this.menu.passEvents = false;
                                  }));

        var vscroll = this.categoriesScrollBox.get_vscroll_bar();
        vscroll.connect('scroll-start',
                        Lang.bind(this, function() {
                                      this.menu.passEvents = true;
                                  }));
        vscroll.connect('scroll-stop',
                        Lang.bind(this, function() {
                                      this.menu.passEvents = false;
                                  }));

        this._refreshFavs();

        this.separator = new PopupMenu.PopupSeparatorMenuItem();
        this.separator.actor.set_style("padding: 0em 1em;");

        this.appsButton = new AllProgramsItem(_(this.allProgramsLabel), "forward", this, false);

        this.leftPaneBox = new St.BoxLayout({ style_class: 'menu-favorites-box', vertical: true });




        this.rightButtonsBox = new RightButtonsBox(this, this.menu);

        this.rightButtonsBox.actor.style_class = "right-buttons-box";



        this.mainBox = new St.BoxLayout({ style_class: 'menu-applications-box', vertical:false });

        this.applicationsByCategory = {};
        this._refreshApps();

        this.appBoxIter = new VisibleChildIterator(this, this.applicationsBox);
        this.applicationsBox._vis_iter = this.appBoxIter;
        this.catBoxIter = new VisibleChildIterator(this, this.categoriesBox);
        this.categoriesBox._vis_iter = this.catBoxIter;

        this.leftPane.set_child(this.favsBox, { y_align: St.Align.END,y_fill: false });

        this.selectedAppBox.add_actor(this.selectedAppTitle);
        this.selectedAppBox.add_actor(this.selectedAppDescription);
        this.categoriesScrollBox.add_actor(this.categoriesBox);
        this.categoriesScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        this.applicationsScrollBox.add_actor(this.applicationsBox);
        this.applicationsScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        this.categoriesApplicationsBox.actor.add_actor(this.categoriesScrollBox);
        this.categoriesApplicationsBox.actor.add_actor(this.applicationsScrollBox);
        this.appsBox.add_actor(this.selectedAppBox);
        this.appsBox.add_actor(this.categoriesApplicationsBox.actor);
        this.searchBox.add_actor(this.searchEntry);
        this.leftPaneBox.add_actor(this.leftPane);
        this.leftPaneBox.add_actor(this.separator.actor);
        this.leftPaneBox.add_actor(this.appsButton.actor);
        this.leftPaneBox.add_actor(this.searchBox);
        this.mainBox.add_actor(this.leftPaneBox);
        this.mainBox.add_actor(this.rightButtonsBox.actor);
        section.actor.add_actor(this.mainBox);

        Mainloop.idle_add(Lang.bind(this, function() {
            this._clearAllSelections();
        }));
    },

    switchPanes: function(pane) {
        if (pane == "apps") {
            this.leftPane.set_child(this.appsBox);
            this.appsButton.label.set_text(" "+_(this.favoritesLabel));
            this.rightButtonsBox.actor.hide();
            this._appletStyles("apps");
        }else {
            this.leftPane.set_child(this.favsBox);
            this.appsButton.label.set_text(" "+_(this.allProgramsLabel));
            if(this.menu.showQuicklinks)
            {
                this.rightButtonsBox.actor.show();
            }
            this._appletStyles("favs");
        }
        this.rightButtonsBox.shutdown.label.set_text(_(this.shutdownLabel));
    },

    _updateVFade: function() {
        var mag_on = this.a11y_settings.get_boolean("screen-magnifier-enabled");
        if (mag_on) {
            this.applicationsScrollBox.style_class = "menu-applications-scrollbox";
        } else {
            this.applicationsScrollBox.style_class = "vfade menu-applications-scrollbox";
        }
    },

    _update_autoscroll: function() {
        this.applicationsScrollBox.set_auto_scrolling(this.autoscroll_enabled);
    },

    _clearAllSelections: function() {
        var actors = this.applicationsBox.get_children();
        for (var i=0; i<actors.length; i++) {
            var actor = actors[i];
            actor.style_class = "menu-application-button";
            actor.hide();
        }
        var actors = this.categoriesBox.get_children();
        for (var i=0; i<actors.length; i++){
            var actor = actors[i];
            actor.style_class = "menu-category-button";
            actor.show();
        }
    },

    _select_category : function(dir, categoryButton) {
        if (dir)
            this._displayButtons(this._listApplications(dir.get_menu_id()));
        else
            this._displayButtons(this._listApplications(null));
        this.closeApplicationsContextMenus(null, false);
        this._scrollToCategoryButton(categoryButton);
    },

    closeApplicationsContextMenus: function(excludeApp, animate) {
        for (var app in this._applicationsButtons){
            if (app!=excludeApp && this._applicationsButtons[app].menu.isOpen){
                if (animate)
                    this._applicationsButtons[app].toggleMenu();
                else
                    this._applicationsButtons[app].closeMenu();
            }
        }
    },

    _onApplicationButtonRealized: function(actor) {
        if (actor.get_width() > this._applicationsBoxWidth){
            this._applicationsBoxWidth = actor.get_width();
            this.applicationsBox.set_width(this._applicationsBoxWidth + 20);
        }
    },

    _displayButtons: function(appCategory, places, recent, apps, autocompletes){
        var innerapps = this.applicationsBox.get_children();
        for (var i in innerapps) {
            innerapps[i].hide();
        }
        if (appCategory) {
            if (appCategory == "all") {
                this._applicationsButtons.forEach( function (item, index) {
                    if (!item.actor.visible) {
                        item.actor.show();
                    }
                });
            } else {
                this._applicationsButtons.forEach( function (item, index) {
                    if (item.category.indexOf(appCategory) != -1) {
                        if (!item.actor.visible) {
                            item.actor.show();
                        }
                    } else {
                        if (item.actor.visible) {
                            item.actor.hide();
                        }
                    }
                });
            }
        } else if (apps) {
            for (var i = 0; i < this._applicationsButtons.length; i++) {
                    if (apps.indexOf(this._applicationsButtons[i].name) != -1) {
                        if (!this._applicationsButtons[i].actor.visible) {
                            this._applicationsButtons[i].actor.show();
                        }
                    } else {
                        if (this._applicationsButtons[i].actor.visible) {
                            this._applicationsButtons[i].actor.hide();
                        }
                    }
            }
        } else {
            this._applicationsButtons.forEach( function (item, index) {
                    if (item.actor.visible) {
                        item.actor.hide();
                    }
            });
        }
        if (places) {
            if (places == -1) {
                this._placesButtons.forEach( function (item, index) {
                   item.actor.show();
                });
            } else {
                for (var i = 0; i < this._placesButtons.length; i++) {
                    if (places.indexOf(this._placesButtons[i].button_name) != -1) {
                        if (!this._placesButtons[i].actor.visible) {
                            this._placesButtons[i].actor.show();
                        }
                    } else {
                        if (this._placesButtons[i].actor.visible) {
                            this._placesButtons[i].actor.hide();
                        }
                    }
                }
            }
        } else {
            this._placesButtons.forEach( function (item, index) {
                    if (item.actor.visible) {
                        item.actor.hide();
                    }
            });
        }
        if (recent) {
            if (recent == -1) {
                this._recentButtons.forEach( function (item, index) {
                    if (!item.actor.visible) {
                        item.actor.show();
                    }
                });
            } else {
                for (var i = 0; i < this._recentButtons.length; i++) {
                    if (recent.indexOf(this._recentButtons[i].button_name) != -1) {
                        if (!this._recentButtons[i].actor.visible) {
                            this._recentButtons[i].actor.show();
                        }
                    } else {
                        if (this._recentButtons[i].actor.visible) {
                            this._recentButtons[i].actor.hide();
                        }
                    }
                }
            }
        } else {
            this._recentButtons.forEach( function (item, index) {
                    if (item.actor.visible) {
                        item.actor.hide();
                    }
            });
        }
        if (autocompletes) {
            for (var i = 0; i < autocompletes.length; i++) {
                var button = new TransientButton(this, autocompletes[i]);
                button.actor.connect('realize', Lang.bind(this, this._onApplicationButtonRealized));
                button.actor.connect('leave-event', Lang.bind(this, this._appLeaveEvent, button));
                this._addEnterEvent(button, Lang.bind(this, this._appEnterEvent, button));
                this._transientButtons.push(button);
                this.applicationsBox.add_actor(button.actor);
                button.actor.realize();
            }
        }
    },

    _setCategoriesButtonActive: function(active) {
        try {
            var categoriesButtons = this.categoriesBox.get_children();
            for (var i in categoriesButtons) {
                var button = categoriesButtons[i];
                if (active){
                    button.set_style_class_name("menu-category-button");
                } else {
                    button.set_style_class_name("menu-category-button-greyed");
                }
             }
        } catch (e) {
            global.log(e);
        }
     },

     resetSearch: function(){
        this.searchEntry.set_text("");
        this.searchActive = false;
        this._clearAllSelections();
        this._setCategoriesButtonActive(true);
        global.stage.set_key_focus(this.searchEntry);
     },

     _onSearchTextChanged: function (se, prop) {
        if (this.menuIsOpening) {
            this.menuIsOpening = false;
            return false;
        } else {
            var searchString = this.searchEntry.get_text();
            this.searchActive = searchString != '';
            this._fileFolderAccessActive = this.searchActive && this.searchFilesystem;
            this._clearAllSelections();

            if (this.searchActive) {
                this.searchEntry.set_secondary_icon(this._searchActiveIcon);
                if (this._searchIconClickedId == 0) {
                    this._searchIconClickedId = this.searchEntry.connect('secondary-icon-clicked',
                        Lang.bind(this, function() {
                            this.resetSearch();
                            this._select_category(null, this._allAppsCategoryButton);
                        }));
                }
                this._setCategoriesButtonActive(false);
                this._doSearch();
            } else {
                if (this._searchIconClickedId > 0)
                    this.searchEntry.disconnect(this._searchIconClickedId);
                this._searchIconClickedId = 0;
                this.searchEntry.set_secondary_icon(this._searchInactiveIcon);
                this._previousSearchPattern = "";
                this._setCategoriesButtonActive(true);
                this._select_category(null, this._allAppsCategoryButton);
            }
            return false;
        }
    },

    _listBookmarks: function(pattern){
       var bookmarks = Main.placesManager.getBookmarks();
       var res = new Array();
       for (var id = 0; id < bookmarks.length; id++) {
          if (!pattern || bookmarks[id].name.toLowerCase().indexOf(pattern)!=-1) res.push(bookmarks[id]);
       }
       return res;
    },

    _listDevices: function(pattern){
       var devices = Main.placesManager.getMounts();
       var res = new Array();
       for (var id = 0; id < devices.length; id++) {
          if (!pattern || devices[id].name.toLowerCase().indexOf(pattern)!=-1) res.push(devices[id]);
       }
       return res;
    },

    _listApplications: function(category_menu_id, pattern){
        var applist = new Array();
        if (category_menu_id) {
            applist = category_menu_id;
        } else {
            applist = "all";
        }
        var res;
        if (pattern){
            res = new Array();
            for (var i in this._applicationsButtons) {
                var app = this._applicationsButtons[i].app;
                if (app.get_name().toLowerCase().indexOf(pattern)!=-1 || (app.get_description() && app.get_description().toLowerCase().indexOf(pattern)!=-1) ||
                        (app.get_id() && app.get_id().slice(0, -8).toLowerCase().indexOf(pattern)!=-1)) res.push(app.get_name());
            }
        } else res = applist;
        return res;
    },

    _doSearch: function(){
        if (this.leftPane.get_child() == this.favsBox) this.switchPanes("apps");
        var pattern = this.searchEntryText.get_text().replace(/^\s+/g, '').replace(/\s+$/g, '').toLowerCase();
        if (pattern==this._previousSearchPattern) return false;
        this._previousSearchPattern = pattern;
        this._activeContainer = null;
        this._activeActor = null;
        this._selectedItemIndex = null;
        this._previousTreeItemIndex = null;
        this._previousTreeSelectedActor = null;
        this._previousSelectedActor = null;

       // _listApplications returns all the applications when the search
       // string is zero length. This will happend if you type a space
       // in the search entry.
        if (pattern.length == 0) {
            return false;
        }

        var appResults = this._listApplications(null, pattern);
        var placesResults = new Array();
        var bookmarks = this._listBookmarks(pattern);
        for (var i in bookmarks)
            placesResults.push(bookmarks[i].name);
        var devices = this._listDevices(pattern);
        for (var i in devices)
            placesResults.push(devices[i].name);
        var recentResults = new Array();
        for (var i = 0; i < this._recentButtons.length; i++) {
            if (!(this._recentButtons[i] instanceof RecentClearButton) && this._recentButtons[i].button_name.toLowerCase().indexOf(pattern) != -1)
                recentResults.push(this._recentButtons[i].button_name);
        }

        var acResults = new Array(); // search box autocompletion results
        if (this.searchFilesystem) {
            // Don't use the pattern here, as filesystem is case sensitive
            acResults = this._getCompletions(this.searchEntryText.get_text());
        }

        this._displayButtons(null, placesResults, recentResults, appResults, acResults);

        this.appBoxIter.reloadVisible();
        if (this.appBoxIter.getNumVisibleChildren() > 0) {
            var item_actor = this.appBoxIter.getFirstVisible();
            this._selectedItemIndex = this.appBoxIter.getAbsoluteIndexOfChild(item_actor);
            this._activeContainer = this.applicationsBox;
            if (item_actor && item_actor != this.searchEntry) {
                item_actor._delegate.emit('enter-event');
            }
        }
        return false;
    },

    _getCompletion : function(text) {
        if (text.indexOf('/') != -1) {
            if (text.substr(text.length - 1) == '/') {
                return '';
            } else {
                return this._pathCompleter.get_completion_suffix(text);
            }
        } else {
            return false;
        }
    },

    _getCompletions : function(text) {
        if (text.indexOf('/') != -1) {
            return this._pathCompleter.get_completions(text);
        } else {
            return new Array();
        }
    },

    _run : function(input) {
        var command = input;

        this._commandError = false;
        if (input) {
            var path = null;
            if (input.charAt(0) == '/') {
                path = input;
            } else {
                if (input.charAt(0) == '~')
                    input = input.slice(1);
                path = GLib.get_home_dir() + '/' + input;
            }

            if (GLib.file_test(path, GLib.FileTest.EXISTS)) {
                var file = Gio.file_new_for_path(path);
                try {
                    Gio.app_info_launch_default_for_uri(file.get_uri(),
                                                        global.create_app_launch_context());
                } catch (e) {
                    // The exception from gjs contains an error string like:
                    //     Error invoking Gio.app_info_launch_default_for_uri: No application
                    //     is registered as handling this file
                    // We are only interested in the part after the first colon.
                    //var message = e.message.replace(/[^:]*: *(.+)/, '$1');
                    return false;
                }
            } else {
                return false;
            }
        }

        return true;
    }
};

function main(metadata, orientation, panel_height, instance_id) {
    var myApplet = new MyApplet(orientation, panel_height, instance_id);
    return myApplet;
}
