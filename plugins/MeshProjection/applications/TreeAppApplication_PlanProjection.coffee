class TreeAppApplication_PlanProjection extends TreeAppApplication
    constructor: ->
        super()
        
        @name = 'Plane projection'
        @powered_with    = 'SC'
            
        @actions.push
            ico: "img/plan_projection_bouton.png"
            siz: 1
            txt: "Plan projection"
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                plan = @add_item_depending_selected_tree app.data, MeshPlanProjection
        
        
            