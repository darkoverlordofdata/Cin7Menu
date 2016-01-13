function FavoritesBox() {
    this._init();
}

FavoritesBox.prototype = {
    _init: function() {
        this.actor = new St.BoxLayout({ vertical: true });
        this.actor._delegate = this;

        this._dragPlaceholder = null;
        this._dragPlaceholderPos = -1;
        this._animatingPlaceholdersCount = 0;
    },

    _clearDragPlaceholder: function() {
        if (this._dragPlaceholder) {
            this._dragPlaceholder.animateOutAndDestroy();
            this._dragPlaceholder = null;
            this._dragPlaceholderPos = -1;
        }
    },

    handleDragOver : function(source, actor, x, y, time) {
        var app = source.app;

        // Don't allow favoriting of transient apps
        if (app == null || app.is_window_backed() || (!(source instanceof FavoritesButton) && app.get_id() in AppFavorites.getAppFavorites().getFavoriteMap()))
            return DND.DragMotionResult.NO_DROP;

        var favorites = AppFavorites.getAppFavorites().getFavorites();
        var numFavorites = favorites.length;

        var favPos = favorites.indexOf(app);

        var children = this.actor.get_children();
        var numChildren = children.length;
        var boxHeight = this.actor.height;

        // Keep the placeholder out of the index calculation; assuming that
        // the remove target has the same size as "normal" items, we don't
        // need to do the same adjustment there.
        if (this._dragPlaceholder) {
            boxHeight -= this._dragPlaceholder.actor.height;
            numChildren--;
        }

        var pos = Math.round(y * numFavorites / boxHeight);

        if (pos != this._dragPlaceholderPos && pos <= numFavorites) {
            if (this._animatingPlaceholdersCount > 0) {
                var appChildren = children.filter(function(actor) {
                    return (actor._delegate instanceof FavoritesButton);
                });
                this._dragPlaceholderPos = children.indexOf(appChildren[pos]);
            } else {
                this._dragPlaceholderPos = pos;
            }

            // Don't allow positioning before or after self
            if (favPos != -1 && (pos == favPos || pos == favPos + 1)) {
                if (this._dragPlaceholder) {
                    this._dragPlaceholder.animateOutAndDestroy();
                    this._animatingPlaceholdersCount++;
                    this._dragPlaceholder.actor.connect('destroy',
                        Lang.bind(this, function() {
                            this._animatingPlaceholdersCount--;
                        }));
                }
                this._dragPlaceholder = null;

                return DND.DragMotionResult.CONTINUE;
            }

            // If the placeholder already exists, we just move
            // it, but if we are adding it, expand its size in
            // an animation
            var fadeIn;
            if (this._dragPlaceholder) {
                this._dragPlaceholder.actor.destroy();
                fadeIn = false;
            } else {
                fadeIn = true;
            }

            this._dragPlaceholder = new DND.GenericDragPlaceholderItem();
            this._dragPlaceholder.child.set_width (source.actor.height);
            this._dragPlaceholder.child.set_height (source.actor.height);
            this.actor.insert_actor(this._dragPlaceholder.actor,
                                   this._dragPlaceholderPos);
            if (fadeIn)
                this._dragPlaceholder.animateIn();
        }

        var srcIsFavorite = (favPos != -1);

        if (srcIsFavorite)
            return DND.DragMotionResult.MOVE_DROP;

        return DND.DragMotionResult.COPY_DROP;
    },

    // Draggable target interface
    acceptDrop : function(source, actor, x, y, time) {
        var app = source.app;

        // Don't allow favoriting of transient apps
        if (app == null || app.is_window_backed()) {
            return false;
        }

        var id = app.get_id();

        var favorites = AppFavorites.getAppFavorites().getFavoriteMap();

        var srcIsFavorite = (id in favorites);

        var favPos = 0;
        var children = this.actor.get_children();
        for (var i = 0; i < this._dragPlaceholderPos; i++) {
            if (this._dragPlaceholder &&
                children[i] == this._dragPlaceholder.actor)
                continue;

            if (!(children[i]._delegate instanceof FavoritesButton)) continue;

            var childId = children[i]._delegate.app.get_id();
            if (childId == id)
                continue;
            if (childId in favorites)
                favPos++;
        }

        Meta.later_add(Meta.LaterType.BEFORE_REDRAW, Lang.bind(this,
            function () {
                var appFavorites = AppFavorites.getAppFavorites();
                if (srcIsFavorite)
                    appFavorites.moveFavoriteToPos(id, favPos);
                else
                    appFavorites.addFavoriteAtPos(id, favPos);
                return false;
            }));

        return true;
    }
}

