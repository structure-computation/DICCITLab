# Item permettant de réaliser la transformation d'un maillage (rotation, translation, ...)



class MeshTransformationItem extends TreeItem
    constructor: ( name = "Mesh Transformation" ) ->
        super()
        
        @_name.set name
            
        @add_attr
            translation_bounds : 100
            translation_x : new ConstrainedVal( 0, { min: -100, max: 100, div: 20000 } )
            translation_y : new ConstrainedVal( 0, { min: -100, max: 100, div: 20000 } )
            translation_z : new ConstrainedVal( 0, { min: -100, max: 100, div: 20000 } )
            angle_x     : new ConstrainedVal( 0, { min: -180, max: 180 } )
            angle_z     : new ConstrainedVal( 0, { min: -180, max: 180 } )
            angle_n     : new ConstrainedVal( 0, { min: -180, max: 180 } )
        
        @add_output new MeshItem
        
        @m_glob = math.matrix
        
        
        @bind =>
            if @translation_bounds.has_been_modified() or @translation_x.has_been_modified() or @translation_y.has_been_modified() or @translation_z.has_been_modified() or @angle_x.has_been_modified() or @angle_z.has_been_modified() or @angle_n.has_been_modified()
                #maj des bornes pour la translation
                @translation_x.set_params
                    min: -@translation_bounds.get()
                    max: @translation_bounds.get() 
                    div: @translation_bounds.get()*200
                @translation_y.set_params
                    min: -@translation_bounds.get()
                    max: @translation_bounds.get() 
                    div: @translation_bounds.get()*200
                @translation_z.set_params
                    min: -@translation_bounds.get()
                    max: @translation_bounds.get()
                    div: @translation_bounds.get()*200
                
                if @_children[0]? and @_children[0]._mesh?
                 
                    #point translaté    
                    @center = new Point [ @translation_x.get(), @translation_y.get(), @translation_z.get() ]
                    
                    @make_m_glob()
                    @make_transformation()        
        
    accept_child: ( ch ) ->
        true

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


    make_transformation: ()->    
        @_output[0]._mesh.clear()
    
        #construction d'un maillage temporaire non transformé
        mesh_temp = new Mesh
        for i in [ 0..@_children[0]._mesh.points.length-1 ]
            mesh_temp.add_point @_children[0]._mesh.points[i].pos.get()
        mesh_temp.add_element @_children[0]._mesh._elements[0].deep_copy()
        console.log mesh_temp
        
        #rotation et translation de la gauge 
        for i in  [ 0..mesh_temp.points.length-1 ]
            trans_point = new Vec_3
            for j in [ 0..2 ]
                val = @m_glob._data[j][0] * (mesh_temp.points[i].pos[0].get()) + @m_glob._data[j][1] * (mesh_temp.points[i].pos[1].get()) + @m_glob._data[j][2] * (mesh_temp.points[i].pos[2].get())  
                trans_point[j] = val + @center.pos[j].get()  
            @_output[0]._mesh.add_point trans_point
            
        #même table de connectivité
        @_output[0]._mesh.add_element mesh_temp._elements[0].deep_copy()
