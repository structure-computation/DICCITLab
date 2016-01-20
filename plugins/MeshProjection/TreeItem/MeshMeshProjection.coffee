# Item permettant de réaliser la projection d'un maillage sur un autre maillage



class MeshMeshProjection extends TreeItem
    constructor: ( name = "Mesh to Mesh Projection" ) ->
        super()
        
        @_name.set name
        @_viewable.set true
        
        # attributes
        @add_attr
            _has_a_projection : false
            _mesh : new Mesh( not_editable: true )
#             pe : [0,0,0,0]              #paramètre de l'équation du plan pe[0]*x + pe[1]*y + pe[2]*z + pe[3] = 0
            
        @add_attr
            visualization: @_mesh.visualization
        
        
        mesh_1 = new ProjectionContener "Mesh 1"
        mesh_2 = new ProjectionContener "Mesh 2"
        output_0 = new ProjectionContener "Output Mesh"
        
        @add_child mesh_1
        @add_child mesh_2
        
        @add_output output_0
     
    #affichage des actions contextuelles dans la barre verticale gauche de l'interface 
    display_suppl_context_actions: ( context_action )  ->
        instance = this
        context_action.push
            txt: "make projection"
            ico: "img/compute.png"
            fun: ( evt, app ) =>
                instance.test_calcul_projection()
                
#         context_action.push
#             txt: "Apply to object"
#             ico: "img/apply.png"
#             fun: ( evt, app ) =>
#                 if @_has_a_projection
#                     #sauvegarde du mesh dans un nouvel item
#                     output_mesh = new MeshItem
#                     output_mesh._mesh = instance._mesh.deep_copy()
#                     delete output_mesh.visualization
#                     output_mesh.visualization = output_mesh._mesh.visualization
#                 
#                     #sauvegarde du field dans un nouvel item
#                     output = new FieldSetItem    
#                     output.visualization = instance._children[2]._children[0].field_set.deep_copy()
#                     output.visualization.color_by.lst[0].data._data[0].field._mesh = output_mesh._mesh
#                     
#                     if output.visualization.color_by.lst[0].drawing_parameters._legend?
#                         delete output.visualization.color_by.lst[0].drawing_parameters.legend
#                         output.visualization.color_by.lst[0].drawing_parameters.legend = output.visualization.color_by.lst[0].drawing_parameters._legend
#                         
# #                     output.visualization = instance._children[2]._children[0].field_set.deep_copy()
# #                     output.visualization.color_by.lst[0].data._mesh = output_mesh._mesh
# #                     
# #                     if output.visualization.color_by.lst[0].drawing_parameters._legend?
# #                         output.visualization.color_by.lst[0].drawing_parameters.legend = output.visualization.color_by.lst[0].drawing_parameters._legend
# #                     console.log output.visualization.color_by.lst[0].drawing_parameters
#                     
#                     @_output[0].add_child output_mesh
#                     @_output[0].add_child output
     
    #vérification de la présence de l'ensemble des paramètre pour lancer la procédure de rpojection 
    test_calcul_projection:() ->
        make_calcul = true
        if not (@_children[0]._children[0]? and @_children[0]._children[0]._mesh?)
            make_calcul = false
        if not (@_children[1]._children[0]? and @_children[1]._children[0]._mesh?)
            make_calcul = false
            
        if not make_calcul
            alert "bad data initialisation"
        else
            @_mesh.points.clear()
            @_mesh._elements.clear()
        
            mesh1 = @_children[0]._children[0]._mesh
            mesh2 = @_children[1]._children[0]._mesh
            normals_elements_1_set = @normals_elements mesh1                                            #calcul des normales des éléments du mesh 1
            inv_connec_1 = @inverse_connectivity mesh1                                                  #calcul de la table de connectivité inverse du mesh 1
            normals_points_1_set = @normals_points mesh1, normals_elements_1_set, inv_connec_1          #calcul des normales aux points du mesh 1
            eq_plans_set_2 = @eq_plan_elements mesh2                                                    #calcul des equation de plan des éléments du mesh 2
            @make_projection mesh1, mesh2, normals_points_1_set, eq_plans_set_2                         #projection
     
     
    #calcul des normales de tous les éléments d'un maillage
    normals_elements: ( mesh ) ->
        points = mesh.points
        connec = mesh._elements[0].indices
        normals_elements_set = []
        
        for i in [ 0..(connec._size[1])-1 ]
            indices_set = []
            points_set = []
            for j in [ 0..connec._size[0]-1 ]
                indices_set.push connec.get()[ connec._size[0]*i + j ]
            for ind in indices_set
                points_set.push points[ ind ]
            
            v1 = @twopoints_2_vector points_set[0].pos.get(), points_set[1].pos.get()
            v2 = @twopoints_2_vector points_set[1].pos.get(), points_set[2].pos.get()
            
            normal = Vec_3.cro v1, v2
            normals_elements_set.push normal
#         console.log normals_elements_set
        return normals_elements_set
     
     
    #calcul de la table de connectivité inversée d'un maillage
    inverse_connectivity: ( mesh ) ->
        points = mesh.points
        connec = mesh._elements[0].indices
        
        indices_sets_set = []
        for i in [ 0..(connec._size[1])-1 ]
            indices_set = []
            for j in [ 0..connec._size[0]-1 ]
                indices_set.push connec.get()[ connec._size[0]*i + j ]
            indices_sets_set.push indices_set
        
        inv_connec = []
        for p in [ 0..points.length-1 ]
            inv_connec_p = []
            for i in [ 0..indices_sets_set.length-1 ]
                if p in indices_sets_set[i]
                    inv_connec_p.push i
            inv_connec.push inv_connec_p        
        
#         console.log inv_connec
        return inv_connec
        
    
    #calcul des "normales aux points" d'un maillage (moyenne des normales des éléments connectés)
    normals_points: ( mesh, normals_elements_set, inv_connec ) ->
        points = mesh.points
        normals_points_set = []
        
        for p in [ 0..points.length-1 ]
            normals_p = []
            for i in inv_connec[p]
                normals_p.push normals_elements_set[i]
            
            normal_p = new Vec_3
            normal_p = [0,0,0]
            for normal in normals_p
                normal_p = Vec_3.add normal_p, normal
            normals_points_set.push normal_p    
        
        return normals_points_set
                
           
    
    #calcul des paramètres d'équation des plans (ax+by+cz+d=0) des élements d'un maillage (à partir des normales)
    eq_plan_elements: ( mesh ) ->
        points = mesh.points
        connec = mesh._elements[0].indices
        eq_plans_set = []
        
        for i in [ 0..(connec._size[1])-1 ]
            indices_set = []
            points_set = []
            for j in [ 0..connec._size[0]-1 ]
                indices_set.push connec.get()[ connec._size[0]*i + j ]
            for ind in indices_set
                points_set.push points[ ind ]
            
            v1 = @twopoints_2_vector points_set[0].pos.get(), points_set[1].pos.get()
            v2 = @twopoints_2_vector points_set[1].pos.get(), points_set[2].pos.get()
            normal = Vec_3.cro v1, v2  #cro: produit vectoriel 
            
            eq_plan = []
            eq_plan.push normal[0]
            eq_plan.push normal[1]
            eq_plan.push normal[2]
            eq_plan.push ( - points_set[0].pos.get()[0] * normal[0] - points_set[0].pos.get()[1] * normal[1] - points_set[0].pos.get()[2] * normal[2] )
            eq_plans_set.push eq_plan
        
#         console.log eq_plans_set
        return eq_plans_set
            
    
    
    
    #test si les normales aux points passent dans un élément du second maillage, puis projection
    make_projection: ( mesh_1, mesh_2, normals_points_set, eq_plans_set ) ->
        points_1 = mesh_1.points
        points_2 = mesh_2.points
        
        #boucle sur les points du mesh1
        for p in [ 0..points_1.length-1 ]
            normal = normals_points_set[p]
            point = points_1[p]
            
            #boucle sur les plans du mesh2
            for k in [ 0..eq_plans_set.length-1 ]
                plan = eq_plans_set[k]
                
                #point intersection de la droite (point du mesh1 + vecteur normal au point) et du plan
                numerateur = plan[3]
                denominateur = 0
                for i in [0..2]
                    numerateur += plan[i]*point.pos[i].get()
                    denominateur += plan[i]*normal[i]
                t = - numerateur/denominateur

                point_proj = new Point
                for i in [0..2]
                    point_proj.pos[i].set (point.pos[i].get() + t*normal[i] )
                
                
                #récup des 3 points de l'élément associé au plan
                connec_2 = mesh_2._elements[0].indices
                indices_set = []
                points_set = []
                for j in [ 0..connec_2._size[0]-1 ]
                    indices_set.push connec_2.get()[ connec_2._size[0]*k + j ]
                for ind in indices_set
                    points_set.push points_2[ ind ] 
                    
                points_set.push points_set[0]   #ajout du premier point en fin de liste (pour boucler)
                
                #test: point_proj dans le triangle {points_set} ?
                test = []
                for i in [ 0..2 ]
                    a = @twopoints_2_vector points_set[i].pos.get(), points_set[i+1].pos.get()
                    b = @twopoints_2_vector points_set[i].pos.get(), point_proj.pos.get()
                    vp = Vec_3.cro a, b
                    test.push Vec_3.dot vp, normal      #dot: produit scalaire
                if (test[0] >= 0 and test[1] >= 0 and test[2] >= 0) or (test[0] <= 0 and test[1] <= 0 and test[2] <= 0)
#                     console.log "point " + p + " in element " + k + "!"
                    @_mesh.add_point point_proj.pos.get()  
                    break
                
        @_mesh.add_element mesh_1._elements[0].deep_copy()
        @_has_a_projection.set true

            
    #Vec_3 à partir de 2 points
    twopoints_2_vector: ( p1, p2 ) ->
        vec = new Vec_3
        for i in [0..2]
            vec[i] = p2[i] - p1[i]
        return vec    
    
    
    sub_canvas_items: ->
        lst = []
        lst.push @_mesh
        return lst 
    