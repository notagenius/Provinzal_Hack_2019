var config_file = require('./config.json');
var insurance_types = require('./insurance_types.json');
var insurance_demo_data = require('./demo_insurance.json');
var request = require('request');
var extend = require('util')._extend;


var express = require('express');
var app = express();
var path = require('path');
var server = require('http').createServer(app);
var io = require('socket.io')(server);
var express = require('express');
var session = require('express-session');//sessions
var bodyParser = require('body-parser');//sessions
var sessionstore = require('sessionstore'); //sessions
var os = require("os");
var listEndpoints = require('express-list-endpoints'); //for rest api explorer


var config = Object.assign({}, config_file);
var port = process.env.PORT || config.webserver_default_port || 3000;
var hostname = process.env.HOSTNAME || config.hostname || "http://127.0.0.1:" + port + "/";
var appDirectory = require('path').dirname(process.pkg ? process.execPath : (require.main ? require.main.filename : process.argv[0]));
console.log(appDirectory);





var FCM = require('fcm-node');
var serverKey = config.firebase_setup.server_key; //put your server key here
var fcm = new FCM(serverKey);

var last_send_messages = [];

var all_got_transactions = {};

app.set('trust proxy', 1);
app.use(function (req, res, next) {
    if (!req.session) {
        return next(); //handle error
    }
    next(); //otherwise continue
});


// Routing
app.use(express.static(path.join(__dirname, 'public')));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));



app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

server.listen(port, function () {
    console.log('Server listening at port %d', port);
});


app.get('/rest/get_last_transaction', function (req, res) {
    res.json(last_fetch);
});
app.get('/rest/get_transactions', function (req, res) {
    res.json(all_got_transactions);
});
app.get('/rest/get_current_transactions', function (req, res) {
    res.json(current_diff_transactions);
});

app.get('/rest/update_device_token/:token', function (req, res) {
    var token = req.params.token;
    config.firebase_setup.device_token = String(token);
    res.json(config.firebase_setup);
});


app.get('/rest/insurance_types/', function (req, res) {
    res.json(insurance_types);
});

app.get('/rest/last_send_messages/', function (req, res) {
    res.json(last_send_messages);
});


app.get('/rest/update_db_token/:token', function (req, res) {
    var token = req.params.token;
    config.account_data.Authorization = String(token);
    res.json(config.account_data);
});


app.get('/rest/config', function (req, res) {
    res.json(config);
});

app.get('/rest/config_account_data', function (req, res) {
    res.json(config.account_data);
});


app.get('/rest/config_firebase_data', function (req, res) {
    res.json(config.firebase_setup);
});


app.get('/rest/test_push', function (req, res) {
    res.json(send_notification([1,2,3]));
});


app.get('/r/ird/:name', function (req, res) {
    var name = req.params.name;
    var url = "p";
    for (let index = 0; index < insurance_types.length; index++) {
        if (insurance_types[index].short_code == name){
            url = insurance_types[index].url;
            break;
        }  
    }
    res.redirect(url);
});

var last_fetch = {};
var fetch_cleaned = [];
var fetch_portfolio = [];
var last_portfolio = [];
function create_product_portfolio(_data) {
    var tmp = [];
    var dict = {};
    for (let index = 0; index < _data.length; index++) {
        var fn = _data[index];
        if (!fn.paymentReference){continue;}
        var name_cleaned = String(fn.paymentReference).toLocaleLowerCase();
       // console.log(name_cleaned);
        for (let itci = 0; itci < insurance_types.length; itci++) {
            var itc = insurance_types[itci];
            if (name_cleaned.includes(String(itc.creditor_keyword).toLocaleLowerCase())){   
                if (dict[String(itc.insurance_type)] == undefined || dict[String(itc.insurance_type)] == null){
                    dict[String(itc.insurance_type)] = true;
                     console.log("found an insureacnde match " + itc.insurance_type);
                    tmp.push({ itc: itc, transaction: fn });
                }        
                break;
            }
        }
    }
    return tmp;
}


function send_transaction_to_backend(_data) {
    var options = {
        uri: config.backend_endoint_add_transaction,
        method: 'POST',
        json: {
            "recent_stransaction": _data
        }
    };

//    request(options, function (error, response, body) {
//        if (!error && response.statusCode == 200) {
//            console.log(body.id); // Print the shortened url.
//        }
//    });
}


function send_notification(_data) {
    if (_data.length <= 0){
        console.log("no need no send a notification");
        return;
    }
    var options = {
        uri: config.backend_endpoint_notification,
        method: 'POST',
        json: {
            "recent_stransaction": _data
        }
    };

    
    var fcm_data = {};

    for (let index = 0; index < _data.length; index++) {
        const element = _data[index];
        fcm_data[String(element.itc.insurance_type)] = config.host + "/r/ird/" + element.itc.short_code;
        last_send_messages.push(element.itc);
    }
    
    var message = { //this may vary according to the message type (single recipient, multicast, topic, et cetera)
        to: config.firebase_setup.device_token,
        collapse_key: 'your_collapse_key',

        notification: {
            title: 'You got an insurance recommendation',
            body: 'Please open the App to see the recommendation'
        },
        data: fcm_data
    };

    fcm.send(message, function (err, response) {
        if (err) {
            console.log("Something has gone wrong!");
        } else {
            console.log("Successfully sent with response: ", response);
        }
    });

    return fcm_data;
}


function last_db_transactions(_iban) {
    console.log("last_db_transactions for:" + _iban);
    var ac = config.account_data;
    
    if (ac == undefined || ac == null) {
        console.error("-- ac == null --");
        return;
    }
    //console.log("found db user account data" + ac.name);

    var build_request_url = config.deutsche_bank_api_endpoint;
    build_request_url += "?iban=" + ac.iban + "&sortBy=" + ac.sortBy + "&limit=" + ac.limit + "&offset=" + ac.offset;
    console.log(build_request_url);

    console.log(String(ac.Authorization));
    var req_options = {
        url: build_request_url,
        headers: {
            'User-Agent': 'request',
            'accept': 'application/json',
            'Authorization':"Bearer "+ String(ac.Authorization)
        }
    };

    request(req_options, function (error, response, body) {
        console.log('error:', error); // Print the error if one occurred
        console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
        //  console.log('body:', body); // Print the HTML for the Google homepage.
        
        if (response && response.statusCode == 200) {
            var this_time_new = [];
            var tmp = JSON.parse(body);
            all_got_transactions = tmp;
            if (tmp.transactions != undefined && tmp.transactions != null) {
                last_fetch = tmp.transactions;

                for (let trio = 0; trio < last_fetch.length; trio++) {
                    var fn = last_fetch[trio];
                    var is_in = false;

                    for (let tri = 0; tri < fetch_cleaned.length; tri++) {
                        var fc = fetch_cleaned[tri];
                        if (fn.id == fc.id) {
                            is_in = true;
                            break;
                        }
                    }
                    if (!is_in) {
                        fetch_cleaned.push(fn);
                        console.log("added " + String(fn.id) + " " + String(fn.amount));
                        this_time_new.push({ from_iban: fn.originIban, to_iban: fn.counterPartyIban, amount: fn.amount, reason: fn.paymentReference });
                        continue;
                    }
                }
                console.log("--- END ADD RUN ---");
            }
            current_diff_transactions = this_time_new;
            send_transaction_to_backend(this_time_new); //SEND NEW TRANSACTIONS TO THE DATABASE
            fetch_portfolio = create_product_portfolio(fetch_cleaned); //GENERATE PRODUCT PORTFOLIO
            
            //TODO CHECK IF last_portfolio
            var dict = {};
            var diff = []; //HOLDS NEW  INSURANCE ENTRIES DIFFER TO LAST REQUEST

            for (var iddddddndex = 0; iddddddndex < last_portfolio.length; iddddddndex++) {
                const element = last_portfolio[iddddddndex];
                console.log(element.itc);
            }
            for (let index = 0; index < last_portfolio.length; index++) {
                dict[String(last_portfolio[index].itc.insurance_type)] = true;
              //  diff.push(last_portfolio[index]);
            }
            //COPY NEW ENTROIES TO LAST_PORTFOLIO
            for (let index = 0; index < fetch_portfolio.length; index++) {
                var ttmpmp = String(fetch_portfolio[index].itc.insurance_type);
                if (dict[ttmpmp] == undefined){
                    diff.push(fetch_portfolio[index]);
                }   
            }
            //last_portfolio = Object.assign({}, fetch_portfolio); //CLONE! OBJECT
            last_portfolio= fetch_portfolio;
            //SEND 
            console.log("-------- DIFF ----------");
            send_notification(diff);

            var i = 0;
        } else {
            console.log('body:', body);
        }
    });

}

setInterval(() => {
    console.log("starting fetching all db api data");
    last_db_transactions(config.account_data);
}, 20000);

last_db_transactions(config.account_data);

    























//---------------------- FOR REST ENDPOINT LISTING ---------------------------------- //
app.get('/rest', function (req, res) {
    res.redirect('/restexplorer.html');
});

//RETURNS A JSON WITH ONLY /rest ENPOINTS TO GENERATE A NICE HTML SITE
var REST_ENDPOINT_PATH_BEGIN_REGEX = "^\/rest\/(.)*$"; //REGEX FOR ALL /rest/* beginning
var REST_API_TITLE = config.app_name | "APP NAME HERE";
var rest_endpoint_regex = new RegExp(REST_ENDPOINT_PATH_BEGIN_REGEX);
var REST_PARAM_REGEX = "\/:(.*)\/"; // FINDS /:id/ /:hallo/test
//HERE YOU CAN ADD ADDITIONAL CALL DESCTIPRION
var REST_ENDPOINTS_DESCRIPTIONS = [
    { endpoints: "/rest/update/:id", text: "UPDATE A VALUES WITH ID" }

];

app.get('/listendpoints', function (req, res) {
    var ep = listEndpoints(app);
    var tmp = [];
    for (let index = 0; index < ep.length; index++) {
        var element = ep[index];
        if (rest_endpoint_regex.test(element.path)) {
            //LOAD OPTIONAL DESCRIPTION
            for (let descindex = 0; descindex < REST_ENDPOINTS_DESCRIPTIONS.length; descindex++) {
                if (REST_ENDPOINTS_DESCRIPTIONS[descindex].endpoints == element.path) {
                    element.desc = REST_ENDPOINTS_DESCRIPTIONS[descindex].text;
                }
            }
            //SEARCH FOR PARAMETERS
            //ONLY REST URL PARAMETERS /:id/ CAN BE PARSED
            //DO A REGEX TO THE FIRST:PARAMETER
            element.url_parameters = [];
            var arr = (String(element.path) + "/").match(REST_PARAM_REGEX);
            if (arr != null) {
                //SPLIT REST BY /
                var splittedParams = String(arr[0]).split("/");
                var cleanedParams = [];
                //CLEAN PARAEMETER BY LOOKING FOR A : -> THAT IS A PARAMETER
                for (let cpIndex = 0; cpIndex < splittedParams.length; cpIndex++) {
                    if (splittedParams[cpIndex].startsWith(':')) {
                        cleanedParams.push(splittedParams[cpIndex].replace(":", "")); //REMOVE :
                    }
                }
                //ADD CLEANED PARAMES TO THE FINAL JOSN OUTPUT
                for (let finalCPIndex = 0; finalCPIndex < cleanedParams.length; finalCPIndex++) {
                    element.url_parameters.push({ name: cleanedParams[finalCPIndex] });

                }
            }
            //ADD ENPOINT SET TO FINAL OUTPUT
            tmp.push(element);
        }
    }
    res.json({ api_name: REST_API_TITLE, endpoints: tmp });
});