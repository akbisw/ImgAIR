import SwiftyJSON
import Foundation

struct Image {
    let id: String
    let caption: String
    let owner: String
    let created: String
    let fileName: String

    init(id: String, caption: String = "", owner: String = "", fileName: String = "") {
        self.id = id
        self.caption = caption
        self.owner = owner
        self.created = Date().description
        self.fileName = fileName
    }

    func toJSON() -> JSON {
        return JSON([
            "caption": caption,
            "owner": owner,
            "created": created,
        ])
    }
}