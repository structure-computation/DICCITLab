class TreeAppApplication_MeshFit extends TreeAppApplication
    constructor: ->
        super()
        
        @name = 'Mesh Fit'
        @powered_with    = 'SC'
            
        @actions.push
            ico: "img/mesh_fit_bouton.png"
            siz: 1
            txt: "Mesh fit"
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                instance = @add_item_depending_selected_tree app.data, MeshFitItem
        
        
            