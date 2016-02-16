class TreeAppModule_PointReset extends TreeAppModule
    constructor: ->
        super()
        
        @name = 'PointReset'

        _ina = ( app ) =>
            app.data.focus.get() != app.selected_canvas_inst()?[ 0 ]?.cm.view_id

        # effacer tous les points du point set
        @actions.push
            txt: "Reset Points Sets"
            ico: "img/rmpoints.png"
            fun: ( evt, app ) =>  
                items = app.data.selected_tree_items
                for path_item in items
                    item = path_item[ path_item.length - 1 ]
                    app.undo_manager.snapshot()
                    @del_points item


    del_points: ( item ) ->
        for point_set in item._children when point_set instanceof PointSetItem
            for point in point_set._children when point instanceof PointItem
                point_set.rem_child point
        if item._children[0]._children.length > 0 or item._children[1]._children.length > 0
            @del_points item
