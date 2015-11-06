#
class PlanItem extends TreeItem
    constructor: ( name = "Plan" ) ->
        super()
        
        @_name.set name
        @_viewable.set true
        
        # attributes
        @add_attr
            show_point  : new Bool true
            _point      : new PointMesher [ 0, 0, 0 ], 2, 6 
            angle_x     : new ConstrainedVal( 0, { min: -180, max: 180 } )
            angle_z     : new ConstrainedVal( 0, { min: -180, max: 180 } )
            angle_n     : new ConstrainedVal( 0, { min: -180, max: 180 } )
        
        @add_attr
            center      : @_point.point
            width       : 2.0
            _nb_values  : 2  
            _mesh         : new Mesh( not_editable: true )
            normal        : new Vec_3
            
        @add_attr    
            color         : @_mesh.visualization.element_color
        
        
        @_mesh.visualization.display_style.num.set 2
        
        @_v1           = new Vec
        @_v2           = new Vec
        @_v3           = new Vec
        @_v1_scale     = new Vec
        @_v2_scale     = new Vec
        @_v3_scale     = new Vec
        @m_glob        = math.matrix
        
        
        @bind =>
            if @center.has_been_modified() or @width.has_been_modified() or @angle_x.has_been_modified() or @angle_z.has_been_modified() or @angle_n.has_been_modified()
              @make_mesh()
     
     display_suppl_context_actions: ( context_action )  ->
        instance = this
        context_action.push
            txt: "get normal"
            ico: "img/Normal_plan.png"
            fun: ( evt, app ) =>
                instance.calcul_normale()
                instance.add_child_normale()
     
     calcul_normale:() ->
        #calcul de la normale moyenne à l'ensemble des éléments du maillage
#         console.log @_mesh._elements
        
        XM_temp = 0
        YM_temp = 0
        ZM_temp = 0
        n_value_temp = 0
        for i in [ 0 ... @_mesh._elements[0].indices.size( 1 ) ]    
            x1 = @_mesh.points[ @_mesh._elements[0].indices.get [ 0, i ] ].pos[0].get()
            y1 = @_mesh.points[ @_mesh._elements[0].indices.get [ 0, i ] ].pos[1].get()
            z1 = @_mesh.points[ @_mesh._elements[0].indices.get [ 0, i ] ].pos[2].get()
            
            x2 = @_mesh.points[ @_mesh._elements[0].indices.get [ 1, i ] ].pos[0].get()
            y2 = @_mesh.points[ @_mesh._elements[0].indices.get [ 1, i ] ].pos[1].get()
            z2 = @_mesh.points[ @_mesh._elements[0].indices.get [ 1, i ] ].pos[2].get()
            
            x3 = @_mesh.points[ @_mesh._elements[0].indices.get [ 2, i ] ].pos[0].get()
            y3 = @_mesh.points[ @_mesh._elements[0].indices.get [ 2, i ] ].pos[1].get()
            z3 = @_mesh.points[ @_mesh._elements[0].indices.get [ 2, i ] ].pos[2].get()
    
            X = (y2-y1)*(z3-z1) - (z2-z1)*(y3-y1)
            Y = (z2-z1)*(x3-x1) - (x2-x1)*(z3-z1)
            Z = (x2-x1)*(y3-y1) - (y2-y1)*(x3-x1)
            
            #norme
            NN = Math.sqrt(X*X+Y*Y+Z*Z)
            XN = X/NN
            YN = Y/NN
            ZN = Z/NN 
            
            #somme pour le calcul ultérieur de la moyenne
            XM_temp += XN
            YM_temp += YN
            ZM_temp += ZN
            n_value_temp += 1
            
        #vecteur normal moyen
        @normal[0].set (XM_temp/n_value_temp) 
        @normal[1].set (YM_temp/n_value_temp) 
        @normal[2].set (ZM_temp/n_value_temp) 
        

    add_child_normale: () ->  
        normal_vec = new DICCITVectorItem 
        
        normal_vec.center = @center
        normal_vec.vector.set @normal
        normal_vec.make_mesh()
        
        @add_child normal_vec
    
    #calcul de la position des noeuds du maillage de la jauge en position non déformé en fonction du nombre de valeur, de la hauteur et de la largeur   
    fill_v1_v2_v3: () ->    
        width0 =  -(@width.get() / 2)
        height0 =  -(@width.get() / 2)
                
#         console.log width0
#         console.log height0
        
        for i in [ 0 ... @_nb_values.get() ]
            @_v1.push 0
            @_v2.push 0
            @_v1_scale.push 0
            @_v2_scale.push 0
            @_v1[ i ].set (width0 + i * (@width.get())/(@_nb_values.get()-1))
            @_v2[ i ].set (height0 + i * (@width.get())/(@_nb_values.get()-1))
            for j in [ 0 ... @_nb_values.get() ]
                @_v3.push 0
                @_v3_scale.push 0
                
         
        #alert _v3
        for i in [ 0 ... @_nb_values.get() ]
            for j in [ 0 ... @_nb_values.get() ]
                x = @_v1[ i ]
                y = @_v2[ j ]
                str = "x=" + x + "; y=" + y + "; val_z = " + @center.pos[2] + ";"
                val_f = eval(str)
                @_v3[ (i * @_nb_values.get() + j) ].set 0
        

        @_v1_scale = @_v1
        @_v2_scale = @_v2
        @_v3_scale = @_v3
        
    make_m_glob: ()->
        #création de la matrice de rotation à partir des trois angles de rotation d'euler
        rad_x = @angle_x.get() * Math.PI / 180
        rad_z = @angle_z.get() * Math.PI / 180
        rad_n = @angle_n.get() * Math.PI / 180
        m_1 = math.matrix [[math.cos(rad_x), -math.sin(rad_x), 0], [math.sin(rad_x), math.cos(rad_x), 0], [0, 0, 1]]
        m_2 = math.matrix [[1, 0, 0], [0, math.cos(rad_z), -math.sin(rad_z)], [0, math.sin(rad_z), math.cos(rad_z)]]
        m_3 = math.matrix [[math.cos(rad_n), -math.sin(rad_n), 0], [math.sin(rad_n), math.cos(rad_n), 0], [0, 0, 1]]
        m_glob_t1 = math.multiply m_2, m_3
        @m_glob = math.multiply m_1, m_glob_t1

    make_rotation: ()->        
        #construction d'un maillage temporaire non transformé
        mesh_temp = new Mesh
        for i in [ 0 ... @_nb_values.get() ]
            for j in [ 0 ... @_nb_values.get() ]
                mesh_temp.add_point [ @_v1_scale[ i ], @_v2_scale[ j ], @_v3_scale[ (i * @_nb_values.get() + j) ] ]
        
        #rotation et translation du plan
        for i in  [ 0 ... mesh_temp.points.length ]
            trans_point = new Vec_3
            for j in [ 0 ... 3 ]
                val = @m_glob._data[j][0] * (mesh_temp.points[i].pos[0].get()) + @m_glob._data[j][1] * (mesh_temp.points[i].pos[1].get()) + @m_glob._data[j][2] * (mesh_temp.points[i].pos[2].get())  
                trans_point[j] = val + @center.pos[j].get()  
            @_mesh.add_point trans_point
         
        
    make_elem: ()->
        el = new Element_TriangleList
        el.indices.resize [ 3, (2*(@_nb_values.get()-1)*(@_nb_values.get()-1)) ]
        num_element = 0
        for i in [ 0 ... (@_nb_values.get()-1) ]
            for j in [ 0 ... @_nb_values.get()-1 ]
                pt_1 = i * @_nb_values.get() + j
                pt_2 = i * @_nb_values.get() + (j+1)
                pt_3 = (i+1) * @_nb_values.get() + j
                pt_4 = (i+1) * @_nb_values.get() + (j+1)
                
                el.indices.set_val [ 0, num_element ], pt_1
                el.indices.set_val [ 1, num_element ], pt_3
                el.indices.set_val [ 2, num_element ], pt_2
                
                num_element += 1
                
                el.indices.set_val [ 0, num_element ], pt_4
                el.indices.set_val [ 1, num_element ], pt_2
                el.indices.set_val [ 2, num_element ], pt_3
                
                num_element += 1

        @_mesh.add_element el
    
    
    make_mesh: ()->
        @_mesh.points.clear()
        @_mesh._elements.clear()
        
        @fill_v1_v2_v3()
        @make_m_glob()
        @make_rotation() 
        @make_elem()    
 
    cosmetic_attribute: ( name ) ->
        super( name ) or ( name in [ "_point", "_mesh", "color" ] )
    
    accept_child: ( ch ) ->
        
        
    sub_canvas_items: ->
        lst = []
        lst.push @_mesh
        if @show_point.get()
            lst.push @_point
        return lst 
    
    z_index: ->
        @_mesh.z_index()
        
    disp_only_in_model_editor: ->
#         @mesh