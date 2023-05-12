codeunit 50201 NewCustomerCreation
{
    //this is outdated code, move it to WebConnect in a new procedure/rewrite it
    //TableNo = TubberwareCustomer;

    procedure AddCustomer(response: text) result: Boolean
    var
        //TubberwareCustomer: Record TubberwareCustomer;
        jsonConverter: Codeunit 50200;
        JObject: JsonObject;
        JToken: JsonToken;
        CustomerName: Text;
        CustomerLastName: Text;
        Mail: Text;
        IdText: Text;
        IdValue: Integer;
    begin
        JObject.ReadFrom(response);
        IdText := jsonConverter.getFileIdTextAsText(JObject, 'CustomerID');
        Evaluate(IdValue, IdText);
        JObject.Get('CustomerID', JToken);
        CustomerName := jsonConverter.getFileIdTextAsText(JToken.AsObject(), 'CustomerName');
        CustomerLastName := jsonConverter.getFileIdTextAsText(JToken.AsObject(), 'CustomerLastName');
        Mail := jsonConverter.getFileIdTextAsText(JToken.AsObject(), 'CustomerMail');
        //TubberwareCustomer.CustomerID := IdValue;
        //TubberwareCustomer.CustomerName := CustomerName;
        // TubberwareCustomer.CustomerLastName := CustomerLastName;
        //TubberwareCustomer.CustomerMail := Mail;
        Message(Mail);
        // TubberwareCustomer.Insert();
        result := true;
    end;

    //Calls AddCustomer procedure
    procedure ProcessWebhookPayload(payload: Text)
    begin
        AddCustomer(payload);
    end;

}
