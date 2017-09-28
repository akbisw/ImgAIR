import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON

func createImageHandler(request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void {
	Log.info("Handling a post to /images")

	let contentType = request.headers["Content-Type"] ?? "";
	guard let rawData = try! request.readString(),
		contentType.hasPrefix("application/json") else {
		Log.info("No data")
		response.status(.badRequest).send(json: JSON(["error": "No data received"]))
		next()
		return
	}

	let jsonData = JSON.parse(string: rawData)
	Log.info("Heres the image request \(jsonData)")
	do {
		let image = try imagesMapper.insertImage(json: jsonData)

		var json = image.toJSON()

		let baseURL = "http://" + (request.headers["Host"] ?? "localhost:8090")
		let links = JSON(["self": baseURL + "/images/" + image.id])
		json["_links"] = links

		response.status(.OK).send(json: json)
		response.headers["Content-Type"] = "application/hal+json"
	} catch ImagesMapper.RetrieveError.Invalid(let message) {
		response.status(.badRequest).send(json: JSON(["error": message]))
	} catch {
		response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
	}

	next()
}
