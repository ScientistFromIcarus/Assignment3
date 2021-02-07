import ballerina/http;
import ballerina/log;
import ballerina/io;

type Student record {
    string name;
    string address;
    string phonenumber;
    string studentNumber;
    string email;
    int yearOfStudy;
};
Student st1 ={
    name: "Queen Imbili",
    address: "Erf 223, Jackson Rd, Windhoek",
    phonenumber: "0812344182",
    studentNumber: "2100",
    email: "queenimbili6@gmail.com",
    yearOfStudy:2
};
Student st2 ={
    name: "Emma Kenya",
    address: "House 98, R.Mugabe Rd, Windhoek",
    phonenumber: "0813242457",
    studentNumber: "2101",
    email: "emmakenya7@gmail.com",
    yearOfStudy:1
};
map <Student> registeredStudents = {"2100":stu1,"2101":stu2};

listener http:Listener httpListener = new(9091);


@http:ServiceConfig {
    basePath: "/application"
}
service PassengerManagement on httpListener {
    @http:ResourceConfig {
        path : "/student-info",
        methods : ["POST"]
    }
    resource function info(http:Caller caller, http:Request request) returns error? {
       
        http:Response res = new;
        json empty ={};
        
        
        json responseMessage;
        json studentInfoJSON = check request.getJsonPayload();

        log:printInfo("JSON :::" + studentInfoJSON.toString());

        string stNo = studentInfoJSON.studentNumber.toString();
        string courseID = studentInfoJSON.courseID.toString();

        any|error responseOutcome;
        if(registeredStudents.hasKey(stNo)){
            json student = check json.convert(registeredStudents[stNo]);
            Student reqStudent = {
            name: student.name.toString(),
            address: student.address.toString(),
            phonenumber: student.phonenumber.toString(),
            studentNumber:student.studentNumber.toString(),
            email: student.email.toString(),
            yearOfStudy:<int>student.yearOfStudy
            };
            json details =   check (json.convert(reqStudent));
            log:printInfo("Student details:" + details.toString());


            json studentjson = check json.convert(reqStudent);
            responseMessage = {"student":studentjson};
            io:println("Student details");
            io:println(studentjson);
            log:printInfo("All details included in the response:" + studentjson.toString());
            res.setJsonPayload(untaint responseMessage);
            responseOutcome = caller->respond(res);

        }else{
            responseMessage = {"message":"Error:No valid student number provided"};
            res.setJsonPayload(untaint responseMessage);
            io:println(responseMessage);
            responseOutcome = caller->respond(res);
        }

        return;
    }
}
