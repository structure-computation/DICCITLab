class TreeAppApplication_Plan extends TreeAppApplication
    constructor: ->
        super()
        
        @name = 'Plan'
        @powered_with    = 'SC'
            
        @actions.push
            ico: "img/plan_bouton.png"
            siz: 1
            txt: "Plan"
            fun: ( evt, app ) =>
                app.undo_manager.snapshot()
                plan = @add_item_depending_selected_tree app.data, PlanItem
        
        
            