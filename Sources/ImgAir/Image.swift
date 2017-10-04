import SwiftyJSON
import Foundation

struct Image {
    let id: String
    let caption: String
    let owner: String
    let created: String
    let imageData: String

    init(id: String, caption: String = "", owner: String = "", created: String = "", imageData: String = "") {
        self.id = id
        self.caption = caption
        self.owner = owner
        self.created = created
        self.imageData = imageData
    }

    func toJSON() -> JSON {
        return JSON([
            "caption": caption,
            "owner": owner,
            "created": created,
            "data": imageData
        ])
    }
}