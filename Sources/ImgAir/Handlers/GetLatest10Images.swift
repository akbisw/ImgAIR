import CouchDB
import Kitura
import LoggerAPI
import SwiftyJSON

func getLatest10Images(request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void {
    // Retrieve the skip value from the url
    guard let skip: String = request.parameters["skip"] else {
        response.status(.notFound).send(json: JSON(["error": "Not Found"]))
        next()
        return
    }

    Log.info("Handling /images/\(skip)")

    do {
        if let imagesJSON = imagesMapper.getImagesOffset(withSkip: Int(skip)!) {
            var json = imagesJSON
            let baseURL = "http://" + (request.headers["Host"] ?? "localhost:8090")
            let links = JSON(["self": baseURL + "/images/" + skip])
            json["_links"] = links

            response.status(.OK).send(json: json)
            response.headers["Content-Type"] = "applicaion/hal+json"
        }
        else {
            throw ImagesMapper.RetrieveError.NotFound
        }
    } catch ImagesMapper.RetrieveError.NotFound {
        response.status(.notFound).send(json: JSON(["error": "Not found"]))
    } catch {
        response.status(.internalServerError).send(json: JSON(["error": "Could not service request"]))
    }

    next()
}