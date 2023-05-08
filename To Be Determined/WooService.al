// example for sending https requests
// https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/httpcontent/httpcontent-data-type
//Nicolai et AL 2020

codeunit 50250 WooCommerceService
{
    var
        Client: HttpClient;
        //https installtion with SSL hack
        //Ck: Label 'ck_4c4fc7bb9a86d42a667d496cae7d53e3de5f2811';
        //Cs: Label 'cs_f81b6d07ea33de53631240c3a3c37b4faf3e1a46';

        //non https installation with SSL hack:
        //resource: 
        //https://www.schakko.de/2020/09/05/fixing-http-401-unauthorized-when-calling-woocommerces-rest-api/
        //add the following line to Xampp/htdocs/wordpress/.htaccess:
        //SetEnvIf Authorization (.+) HTTPS=on

        Ck: Label 'ck_85a060bf066868da1c40742290aaf79986798d71';
        Cs: Label 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';

    trigger OnRun()
    begin


    end;

    //see:
    //https://woocommerce.github.io/woocommerce-rest-api-docs/#list-all-customers
    //https://woocommerce.com/document/woocommerce-rest-api/
    procedure CallWordPressWSCustomers()
    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        JsonBody: JsonObject;
    begin
        SetAuth();
        //It is a GET, but somehow POST is needed !!
        CreateHttpRequestMessage('POST', 'http:/localhost:80/wordpress/wp-json/wc/v2/customers/1', '', Request);

        if Client.Send(Request, Response) then begin
            //Message('Success');
            JsonBody := GetBodyAsJsonObject(Response);
            Message('Email: ' + getFieldTextAsText(JsonBody, 'email'));

        end else begin
            Message('Not a Success: ' + Format(response.HttpStatusCode));
        end;


    end;



    procedure createstudentjs(student: Text) result: Boolean
    var
        JsonObj: JsonObject;
        //studentRec: Record Student;
        JStudentNameToken: JsonToken;
        JStudentLastNameToken: JsonToken;
        studentName: Text[50];
    begin
        JsonObj.ReadFrom(student);
        JsonObj.Get('name', JStudentNameToken);
        JsonObj.Get('lastname', JStudentLastNameToken);

        //studentRec.Init();
        //studentRec.Validate(Name, JStudentNameToken.AsValue().AsText());
        //studentRec.Validate(Name, getFieldTextAsText(JsonObj, 'name'));
        //studentRec.Validate(LastName, JStudentLastNameToken.AsValue().AsText());

        //if not studentRec.Insert(true) then
        result := false;
        result := true;
    end;



    procedure ModifyItem(Item: Record Item) JsonBody: JsonObject
    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        Body: Text;
        Url: Text;
    begin
        // proof of concept, edit name
        JsonBody.Add('name', Item.Description);
        JsonBody.Add('regular_price', Format(Item."Unit Price"));
        JsonBody.WriteTo(Body);

        Url := 'https://localhost/wordpress/wp-json/wc/v3/products/' + Format(1);

        CreateHttpRequestMessage('PUT', Url, Body, Request);

        if Client.Send(Request, Response) then begin
            JsonBody := GetBodyAsJsonObject(Response);
        end;
    end;

    procedure InsertItem(Item: Record Item) JsonBody: JsonObject
    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;

    begin
        CreateHttpRequestMessage('POST', 'https://localhost/wordpress/wp-json/wc/v3/products', '', Request);

        if Client.Send(Request, Response) then begin
            JsonBody := GetBodyAsJsonObject(Response);
        end;
    end;



    local procedure SetAuth()
    begin
        if not (Client.DefaultRequestHeaders.Contains('User-Agent') and
            Client.DefaultRequestHeaders.Contains('Authorization')
        ) then begin
            Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
            Client.DefaultRequestHeaders.Add('Authorization', CreateAuthString());
        end;
    end;




    // https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/httpcontent/httpcontent-data-type
    local procedure CreateHttpRequestMessage(Method: Text; Url: Text; Body: Text; Request: HttpRequestMessage)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        Content.WriteFrom(Body);

        Content.GetHeaders(headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.Content := Content;
        Request.SetRequestUri(Url);
        Request.Method := Method;
    end;



    /// <summary>
    /// http://dankinsella.blog/http-basic-authentication-with-the-al-httpclient/
    /// https://github.com/microsoft/ALAppExtensions/blob/main/BREAKINGCHANGES.md    
    /// 
    /// Error: 'Codeunit "Type Helper"' does not contain a definition for 'ConvertValueToBase64'
    /// Solution: Function has been moved to codeunit 4110 "Base64 Convert", function ToBase64
    /// </summary>
    /// <returns></returns>
    local procedure CreateAuthString() AuthString: Text
    var
        TypeHelper: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', Ck, Cs);
        AuthString := TypeHelper.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
    end;

    local procedure GetBodyAsJsonObject(Response: HttpResponseMessage) JsonBody: JsonObject
    var
        Body: Text;
    begin
        Response.Content.ReadAs(Body);
        JsonBody.ReadFrom(Body);
    end;

    local procedure getFieldTextAsText(JObject: JsonObject; fieldName: Text): Text
    var
        returnVal: Text;
        JToken: JsonToken;
    begin
        if JObject.Get(fieldName, JToken) then
            returnVal := JToken.AsValue().AsText();

        exit(returnVal);
    end;
}