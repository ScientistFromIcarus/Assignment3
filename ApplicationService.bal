import ballerina/log;
import ballerina/http;
import ballerinax/docker;
import ballerina/io;


type Application record {
    string studentNumber;
    string courseID;
    string ApplicationStatus;
};


http:Client studentMgtEP = new("http://localhost:9091/application");


listener http:Listener httpListener = new(9090);


@http:ServiceConfig {
    basePath:"/status"
}
service ExamManagement on httpListener {
   
    @http:ResourceConfig {
        path : "/remark",
        methods: ["POST"],
        consumes: ["application/json"],
        produces: ["application/json"]
    }
    resource function statusManager(http:Caller caller, http:Request request) returns error? {
        http:Response response = new;
        json reqPayload;

        
        var payload = request.getJsonPayload();
        if (payload is json) {
            reqPayload = payload;
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            checkpanic caller->respond(response);
            return;
        }

        json stuNo = reqPayload.studentNumber;
        json course = reqPayload.courseID;


        
        if (stuNo == null || course == null ) {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Bad Request - Invalid Remark Request payload"});
            checkpanic caller->respond(response);
            return;
        }

        
        application accepted = {
            studentNumber: stNo.toString(),
            courseID:course.toString()
        };

        log:printInfo("Calling student:");

        json responseMessage;
        http:Request studentManagerReq = new;
        json remarkjson = check json.convert(paperForRemark);
        studentManagerReq.setJsonPayload(untaint remarkjson);
        http:Response studentResponse=  check studentMgtEP->post("/student-info", studentManagerReq);
        json studentResponseJSON = check studentResponse.getJsonPayload();

       
        json remarkFullDetails ={"Student ":studentResponseJSON,"Application status":"SUPERVISOR RESPONSE"};
        
        responseMessage = {"Message":"Application status received"};
        response.setJsonPayload(responseMessage);
        checkpanic caller->respond(response);
        return;
    }
}