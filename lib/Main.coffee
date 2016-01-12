
#main = (metadata, orientation)-> new TestApplet(orientation)
main = (metadata, orientation, panel_height, instance_id) -> new MenuApplet(orientation, panel_height, instance_id)
