# Item permettant de réaliser la projection d'un maillage sur un plan en suivant un vecteur de projection



class MeshPlanProjection extends TreeItem
    constructor: ( name = "MeshPlanProjection" ) ->
        super()
        
        @_name.set name
        @_viewable.set true
        
        # attributes
        @add_attr
            _has_a_projection : false
            _mesh : new Mesh( not_editable: true )
            pe : [0,0,0,0]              #paramètre de l'équation du plan pe[0]*x + pe[1]*y + pe[2]*z + pe[3] = 0
            
        @add_attr
            visualization: @_mesh.visualization
        
        
        plan = new MeshPlanProjectionContener "plan"
        vector = new MeshPlanProjectionContener "vector"
        objet_to_project = new MeshPlanProjectionContener "object to project"
        output_0 = new MeshPlanProjectionContener "output"
        
        @add_child plan
        @add_child vector
        @add_child objet_to_project
        
        @add_output output_0
     
    #affichage des actions contextuelles dans la barre verticale gauche de l'interface 
    display_suppl_context_actions: ( context_action )  ->
        instance = this
        context_action.push
            txt: "make projection"
            ico: "img/compute.png"
            fun: ( evt, app ) =>
                instance.test_calcul_projection()
                
        context_action.push
            txt: "Apply to object"
            ico: "img/apply.png"
            fun: ( evt, app ) =>
                if @_has_a_projection
                    #sauvegarde du mesh dans un nouvel item
                    output_mesh = new MeshItem
                    output_mesh._mesh = instance._mesh.deep_copy()
                    delete output_mesh.visualization
                    output_mesh.visualization = output_mesh._mesh.visualization
                
                    #sauvegarde du field dans un nouvel item
                    output = new FieldSetItem    
                    output.visualization = instance._children[2]._children[0].field_set.deep_copy()
                    output.visualization.color_by.lst[0].data._data[0].field._mesh = output_mesh._mesh
                    
                    if output.visualization.color_by.lst[0].drawing_parameters._legend?
                        delete output.visualization.color_by.lst[0].drawing_parameters.legend
                        output.visualization.color_by.lst[0].drawing_parameters.legend = output.visualization.color_by.lst[0].drawing_parameters._legend
                        
#                     output.visualization = instance._children[2]._children[0].field_set.deep_copy()
#                     output.visualization.color_by.lst[0].data._mesh = output_mesh._mesh
#                     
#                     if output.visualization.color_by.lst[0].drawing_parameters._legend?
#                         output.visualization.color_by.lst[0].drawing_parameters.legend = output.visualization.color_by.lst[0].drawing_parameters._legend
#                     console.log output.visualization.color_by.lst[0].drawing_parameters
                    
                    @_output[0].add_child output_mesh
                    @_output[0].add_child output
     
    #vérification de la présentce de l'ensemble des paramètre pour lancer la procédure de rpojection 
    test_calcul_projection:() ->
        make_calcul = true
        if not (@_children[0]._children[0]? and @_children[0]._children[0] instanceof PlanItem)
            make_calcul = false
        if not (@_children[1]._children[0]? and @_children[1]._children[0] instanceof DICCITVectorItem)
            make_calcul = false
        if not (@_children[2]._children[0]? and @_children[2]._children[0]._mesh?)
            make_calcul = false
        
        if not make_calcul
            alert "bad data initialisation"
        else
            @calcul_projection()
     
    #calcul de la projection : projection des points du maillage sur le plan suivant le vecteur de projection   
    calcul_projection:() ->
        #calcul des paramètre de l'équation du plan
        plan = @_children[0]._children[0]
        plan.calcul_normale()
        constante = -(plan.normal[0].get() * plan.center.pos[0].get() + plan.normal[1].get() * plan.center.pos[1].get() + plan.normal[2].get() * plan.center.pos[2].get())
        @pe[0].set plan.normal[0].get()
        @pe[1].set plan.normal[1].get()
        @pe[2].set plan.normal[2].get()
        @pe[3].set constante
    
        #initialisation des variables
        @_mesh.points.clear()
        @_mesh._elements.clear()
        v         = @_children[1]._children[0].vector                   # vecteur de projection
        mesh_temp = @_children[2]._children[0]._mesh                    # maillage à projeter
        
        #boucle sur les points à pojeter
        for i in  [ 0 ... mesh_temp.points.length ]
            pos = mesh_temp.points[i].pos
            numerateur = @pe[3].get()
            for j in [ 0 ... 3 ]
                numerateur += @pe[j].get() * pos[j].get()
                
            denominateur = 0
            for j in [ 0 ... 3 ]
                denominateur += @pe[j].get() * v[j].get()
            
            t = -numerateur/denominateur
            
            proj_point = new Vec_3
            for j in [ 0 ... 3 ]
                proj_point[j] = v[j].get() * t + pos[j].get()
            @_mesh.add_point proj_point  
            
        @_mesh.add_element mesh_temp._elements[0].deep_copy()
        @_has_a_projection.set true
    
    
    sub_canvas_items: ->
        lst = []
        lst.push @_mesh
        return lst 
    