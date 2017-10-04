import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON
 
func getAllImagesHandler(request: RouterRequest, response: RouterResponse, next: ()-> Void) -> Void {
    Log.info("Handling /images")
    if let images = imagesMapper.getAll() {
        var json = JSON([:])
    	let baseURL = "http://" + (request.headers["Host"] ?? "localhost:8090")
    	let links = JSON(["self": baseURL + "/images"])
    	json["_links"] = links
    	// Add _links to each image using the transform method on the array 
        json["_embedded"] = JSON(images.map {
								var image = $0.toJSON()
								image["_links"] = JSON(["self": baseURL + "/images/" + $0.id])
								return image
							})
        json["count"].int = images.count
 
        response.status(.OK).send(json: json)
	response.headers["Content-Type"] = "applicaion/hal+json"
    } else {
        response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
    }
    next()
}