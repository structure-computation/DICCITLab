class MeshProjectionDemoItem extends TreeItem
    constructor: (name = 'Mesh projection')->
        super()
                
        @_name.set name
        
        @add_attr
            edited_by : 'SC'
            stamp: "img/mesh_projection_icone.png"
            txt: "MeshProjection"
            demo_app : "MeshProjectionDemoItem"
            directory : "MeshProjection"
            video_link : undefined
            publication_link : undefined

    associated_application: ()->
        apps = new Lst
        apps.push new TreeAppApplication_MeshProjection
        apps.push new TreeAppApplication_Plot3D
        return apps
    
    run_demo : (app_data)->
        app = new TreeAppApplication
        b = app.add_item_depending_selected_tree app_data, MeshMeshProjection
        
            
    onclick_function: ()->
        window.location = "softpage.html#" +  @demo_app
