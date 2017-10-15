import CouchDB
import Foundation
import LoggerAPI
import SwiftyJSON


class ImagesMapper {
	enum RetrieveError: Error {
		case NotFound
		case Invalid(String)
		case Unknown
	}

	let database: Database;

	init(withDatabase db: Database) {
		self.database = db
	}

	///
	/// Get All Images
	///
	func getAll() -> [Image]? {
		var images: [Image]?

	    database.queryByView("all_images", ofDesign: "main_design", usingParameters: [.descending(true)]) {
            (document: JSON?, error: NSError?) in
            if let document = document, error == nil {
                // create an array of Books from document
                if let list = document["rows"].array {
                    images = list.map {
                        let data = $0["value"];
                        let imageId = data["_id"].stringValue + ":" + data["_rev"].stringValue
                        // Retrieve the Base64 image data
                        let imageData = data["image"]["data"].stringValue
                        return Image(id: imageId, caption: data["caption"].stringValue,
                            owner: data["owner"].stringValue, imageData: imageData)
                    }
                }
            } else {
                Log.error("Something went wrong; could not fetch all images.")
                if let error = error {
                    Log.error("CouchDB error: \(error.localizedDescription). Code: \(error.code)")
                }
            }
        }
        return images
	}

	///
	/// Get images after the offset amount in descending order
	///
	func getImagesOffset(withSkip skip: Int) -> JSON? {
		var responseJSON: JSON?

	    database.queryByView("all_images", ofDesign: "main_design", usingParameters: [.skip(skip),.limit(10),.descending(true)]) {
            (document: JSON?, error: NSError?) in
            if let document = document, error == nil {
                // create an array of Books from document
                responseJSON = document
            } else {
                Log.error("Something went wrong; could not fetch all images.")
                if let error = error {
                    Log.error("CouchDB error: \(error.localizedDescription). Code: \(error.code)")
                }
            }
        }

        return responseJSON
	}

	///
	/// Add an image to the database
	///
	func insertImage(json: JSON) throws -> Image {
		// if theres caption or owner, fill it in
		let caption = json["caption"].stringValue
		let owner = json["owner"].stringValue

		guard let type =  json["_attachments"]["content_type"].string,
		let imageData = json["_attachments"]["data"].string else {
			throw RetrieveError.Invalid("An Image must have filetype and BASE64 Image data")
		}

		// Check if image is either JPEG GIF OR PNG
		let dataURLPattern = "^data:image/(png|jpeg|gif);base64,[^\"]*$"
		if imageData.range(of: dataURLPattern, options: .regularExpression, range: nil, locale: nil) == nil {
			throw RetrieveError.Invalid("Not a proper data URL formatted image.")
		}

		// create a JSON object to store image properties
		let imageJSON = JSON([
			"type": "image",
			"owner": owner,
			"caption": caption,
			"created": Date().timeIntervalSince1970,
			"image": ["content_type": type, "data": imageData]
		])

		Log.info("Heres the image request \(imageJSON)")
		var image: Image?
		database.create(imageJSON) { (id, revision, document, err) in
            if let id = id, let revision = revision, err == nil {
                Log.info("Created image object with id of \(id)")
                let imageId = "\(id):\(revision)"
                image = Image(id: imageId, caption: caption, owner: owner)
                return
            }
		}

		if image == nil {
			Log.info("Database returned nil object. Could not insert image.")
			throw RetrieveError.Unknown
		}

		return image!
	}
}