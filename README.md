# ImgAIR
Image Sharing Site built with Kitura

## Setup CouchDB
Create a docker volume for persistence: ```docker volume create couchdb```

Start the container:
```docker run -d -p 5984:5984 -v couchdb:/opt/couchdb/data apache/couchdb```

Create admin user (otherwise anyone is allowed to login) using web ui: 
http://localhost:5984/_utils/#createAdmin/nonode@nohost

Create a new view in couchDB to return all images

```curl -X PUT "$HOST/image_db/_design/main_design" -d @scripts/main_design.json```

## Setup Kitura & Swift
Swift Installation on Ubuntu: https://gist.github.com/Azoy/8c47629fa160878cf359bf7380aaaaf9

Swift Installation on Windows 10 Bash: https://gist.github.com/Azoy/f10639133aa41cd21e7aecb028263647

Clone the repository: https://github.com/akbisw/ImgAIR.git

Change directory to the project directory:
```git clone https://github.com/akbisw/ImgAIR.git```

Build Project:
```swift build```

Run Project:
```./.build/debug/ImgAir```

Allow-Control-Allow-Origin:
https://chrome.google.com/webstore/category/extensions?hl=en

Open the following url:
http://localhost:8090

## REST API
### Post an Image from local directory
```curl -i -X POST http://localhost:8090/images -H "Content-Type: application/json" -d '{"owner": "Amit Biswas", "caption": "Some Caption", "_attachments": {"content_type": "image/gif", "data": "'"$(base64 -w 0 example.gif)"'"} }'```
