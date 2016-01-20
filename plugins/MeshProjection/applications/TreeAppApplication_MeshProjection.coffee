class TreeAppApplication_MeshProjection extends TreeAppApplication
    constructor: ->
        super()
        
        @name = 'Mesh projection'
        @powered_with    = 'SC'
            
        @actions.push
            ico: "img/mesh_projection_bouton.png"
            siz: 1
            txt: "Mesh projection"
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                plan = @add_item_depending_selected_tree app.data, MeshMeshProjection
        
        
            