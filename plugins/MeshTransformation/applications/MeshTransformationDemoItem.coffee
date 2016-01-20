class MeshTransformationDemoItem extends TreeItem
    constructor: (name = 'Mesh transformation')->
        super()
                
        @_name.set name
        
        @add_attr
            edited_by : 'SC'
            stamp: "img/mesh_transformation_icone.png"
            txt: "MeshTransformation"
            demo_app : "MeshTransformationItem"
            directory : "MeshTransformation"
            video_link : undefined
            publication_link : undefined

    associated_application: ()->
        apps = new Lst
        apps.push new TreeAppApplication_MeshTransformation
        apps.push new TreeAppApplication_Plot3D
        return apps
    
    run_demo : (app_data)->
        app = new TreeAppApplication
        b = app.add_item_depending_selected_tree app_data, MeshTransformationItem
        
            
    onclick_function: ()->
        window.location = "softpage.html#" +  @demo_app
