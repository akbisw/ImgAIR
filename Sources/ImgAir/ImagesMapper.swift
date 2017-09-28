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
		let caption = json["caption"].string ?? ""
		let owner = json["owner"].string ?? ""
		
		// create a JSON object to store image properties
		let imageJSON = JSON([
			"type": "image",
			"owner": owner,
			"caption": caption,
		])
		var image: Image?
		database.create(imageJSON) { (id, revision, document, err) in
            if let id = id, let revision = revision, err == nil {
                Log.info("Created image with id of \(id)")
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
