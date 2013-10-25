var http = require("http");
var url = require("url");
http.createServer(function(req , res){
    res.writeHead(200,{"Content-Type" : "text/plain"});
    if (url.parse(req.url,true).query.type == "no") {
        res.end("[{name : \"hello world\"}]");
        console.log("没有跨域");
    }
    else {
        var callbackname = url.parse(req.url,true).query.callback;
        res.end(callbackname+"([{name : \"hello world\"}])");
        console.log("跨域");
    }
}).listen(8080,"127.0.0.1");