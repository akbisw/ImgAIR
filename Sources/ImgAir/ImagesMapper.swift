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
	/// Add an image to the database
	///
	func insertImage(json: JSON) throws -> Image {
		// if theres caption or owner, fill it in
		let caption = json["caption"].stringValue
		let owner = json["owner"].stringValue

		guard let type =  json["_attachments"]["content_type"].string,
		let imageData = json["_attachments"]["data"].string else {
			throw RetrieveError.Invalid("An Image must have filename and BASE64 Image data")
		}

		// Create attachment JSON
		let attachmentJSON: JSON = [
            "content_type": type,
            "data": imageData
        ]

		// create a JSON object to store image properties
		let imageJSON = JSON([
			"type": "application/json",
			"owner": owner,
			"caption": caption,
			"created": Data().description,
			"_attachments": attachmentJSON
		])
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
