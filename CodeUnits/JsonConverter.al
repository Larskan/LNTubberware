
//1) Functions for retrieving JSON data from URL
//2) Parse the data as a JsonObject
//3) Retrieve values from JsonObject based on field names
codeunit 50200 JsonConverter
{
    //Takes URL input as returns HTTP Response object
    procedure ConnectWithUrl(urlIn: Text): HttpResponseMessage
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        Uri: Text;
    begin
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');

        Uri := urlIn;
        Request.SetRequestUri(Uri);
        Request.Method('GET');
        if Client.Send(Request, Response) then begin
            exit(Response)
        end;
    end;

    //Takes JsonObject and fieldname to return text of the fieldname
    procedure getFileIdTextAsText(JObject: JsonObject; Fieldname: Text): Text
    var
        returnVal: Text;
        JToken: JsonToken;
    begin
        //GET retrieves value of fieldname
        if JObject.Get(Fieldname, JToken) then
            //Converts the fieldname to text
            returnVal := JToken.AsValue().AsText();
        exit(returnVal);
    end;

    //JsonObject+fieldname = JsonArray
    procedure getFileIdTextAsJSArray(JObject: JsonObject; FildName: Text): JsonArray
    var
        JtokenRatings: JsonToken;
        returnArry: JsonArray;
    begin
        if JObject.Get(FildName, JtokenRatings) then begin
            returnArry := JtokenRatings.AsArray();
            exit(returnArry);
        end;
    end;

    //Takes HTTP Response and returns JsonObject
    procedure getBodyAsJsonObject(response: HttpResponseMessage): JsonObject
    var
        returnJObject: JsonObject;
        data: Text;
    begin
        if response.Content().ReadAs(data) then
            //ReadFrom: Reads the Json data from the string
            returnJObject.ReadFrom(data);
        exit(returnJObject);
    end;
}


