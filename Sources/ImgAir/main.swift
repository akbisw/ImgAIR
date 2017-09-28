import CouchDB
import DotEnv
import Foundation
import HeliumLogger
import Kitura
import LoggerAPI
import SwiftyJSON

// Disable buffering on log output
setbuf(stdout, nil)

// Attach a logger
Log.logger = HeliumLogger()

// Database connection. Read the .env file for db credentials
let env = DotEnv()

let connectionProperties = ConnectionProperties(
    host: env.get("DB_HOST") ?? "localhost",
    port: Int16(env.getAsInt("DB_PORT") ?? 5984),
    secured: env.getAsBool("DB_HTTPS") ?? false,
    username: env.get("DB_USERNAME") ?? "",
    password: env.get("DB_PASSWORD") ?? ""
)
let databaseName = env.get("DB_NAME") ?? "image_db"

let client = CouchDBClient(connectionProperties: connectionProperties)
let database = client.database(databaseName)
let imagesMapper = ImagesMapper(withDatabase: database)

// setup routes
let router = Router()
router.all("/static", middleware: StaticFileServer())
//router.get("/", handler: displayImagesHandler)

//router.get("/images", handler: displayImagesHandler)
//router.get("/images/:id", handler: getImageHandler)
router.post("/images", handler: createImageHandler)
//router.update("/images/:id", handler: updateImageHandler)

// Start server
Log.info("Starting server")
let port = env.getAsInt("APP_PORT") ?? 8080
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
