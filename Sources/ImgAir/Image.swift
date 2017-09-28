import SwiftyJSON
import Foundation

struct Image {
    let id: String
    let caption: String
    let owner: String
    let created: String

    init(id: String, caption: String = "", owner: String = "") {
        self.id = id
        self.caption = caption
        self.owner = owner
        self.created = Date().description
    }

    func toJSON() -> JSON {
        return JSON([
            "caption": caption,
            "owner": owner,
            "created": created,
        ])
    }
}
