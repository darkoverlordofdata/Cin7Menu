/* VisibleChildIterator takes a container (boxlayout, etc.)
 * and creates an array of its visible children and their index
 * positions.  We can then work thru that list without
 * mucking about with positions and math, just give a
 * child, and it'll give you the next or previous, or first or
 * last child in the list.
 *
 * We could have this object regenerate off a signal
 * every time the visibles have changed in our applicationBox,
 * but we really only need it when we start keyboard
 * navigating, so increase speed, we reload only when we
 * want to use it.
 */

function VisibleChildIterator(parent, container) {
    this._init(parent, container);
}

VisibleChildIterator.prototype = {
    _init: function(parent, container) {
        this.container = container;
        this._parent = parent;
        this._num_children = 0;
        this.reloadVisible();
    },

    reloadVisible: function() {
        this.visible_children = new Array();
        this.abs_index = new Array();
        var children = this.container.get_children();
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (child.visible) {
                this.visible_children.push(child);
                this.abs_index.push(i);
            }
        }
        this._num_children = this.visible_children.length;
    },

    getNextVisible: function(cur_child) {
        if (this.visible_children.indexOf(cur_child) == this._num_children-1)
            return cur_child;
        else
            return this.visible_children[this.visible_children.indexOf(cur_child)+1];
    },

    getPrevVisible: function(cur_child) {
        if (this.visible_children.indexOf(cur_child) == 0)
            return cur_child;
        else
            return this.visible_children[this.visible_children.indexOf(cur_child)-1];
    },

    getFirstVisible: function() {
        return this.visible_children[0];
    },

    getLastVisible: function() {
        return this.visible_children[this._num_children-1];
    },

    getNumVisibleChildren: function() {
        return this._num_children;
    },

    getAbsoluteIndexOfChild: function(child) {
        return this.abs_index[this.visible_children.indexOf(child)];
    }
};

