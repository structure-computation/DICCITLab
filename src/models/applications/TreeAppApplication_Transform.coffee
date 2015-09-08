class TreeAppApplication_Transform extends TreeAppApplication
    constructor: ->
        super()
         
        @name = 'Transform apps'
        @powered_with    = 'SC'
        
        _ina = ( app ) =>
            app.data.focus.get() != app.selected_canvas_inst()?[ 0 ]?.cm.view_id
        
        
        #unv reader application 3D   
        @actions.push
            ico: "img/test_bouton.png"
            siz: 1
            txt: "Transform item"
            ina: _ina
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                test = @add_item_depending_selected_tree app.data, TransformItem