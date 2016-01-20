class TreeAppApplication_MeshTransformation extends TreeAppApplication
    constructor: ->
        super()
        
        @name = 'Mesh Transformation'
        @powered_with    = 'SC'
            
        @actions.push
            ico: "img/mesh_transf_bouton.png"
            siz: 1
            txt: "Mesh transformation"
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                instance = @add_item_depending_selected_tree app.data, MeshTransformationItem
        
        
            