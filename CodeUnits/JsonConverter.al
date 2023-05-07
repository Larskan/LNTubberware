codeunit 50102 WebJasonConvertor
{

    procedure ConnectWithUrl(urlInd: Text): HttpResponseMessage
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

        Uri := urlInd;
        Request.SetRequestUri(Uri);
        Request.Method('GET');
        if Client.Send(Request, Response) then begin
            exit(Response)
        end;
    end;

    procedure getFileIdTextAsText(JObject: JsonObject; Fieldname: Text): Text
    var
        returnVal: Text;
        JToken: JsonToken;
    begin
        if JObject.Get(Fieldname, JToken) then
            returnVal := JToken.AsValue().AsText();
        exit(returnVal);
    end;

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

    procedure getBodyAsJsonObject(response: HttpResponseMessage): JsonObject
    var
        returnJObject: JsonObject;
        data: Text;
    begin
        if response.Content().ReadAs(data) then
            returnJObject.ReadFrom(data);
        exit(returnJObject);
    end;
}


