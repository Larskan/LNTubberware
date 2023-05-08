codeunit 50201 NewCustomerCreation
{
    TableNo = TubberwareCustomer;

    procedure AddCustomer(response: text) result: Boolean
    var
        TubberwareCustomer: Record TubberwareCustomer;
        jsonConverter: Codeunit 50200;
        JObject: JsonObject;
        JToken: JsonToken;
        CustomerName: Text;
        Mail: Text;
        IdText: Text;
        IdValue: Integer;
    begin
        JObject.ReadFrom(response);
        IdText := jsonConverter.getFileIdTextAsText(JObject, 'ID');
        Evaluate(IdValue, IdText);
        JObject.Get('Cus', JToken);
        CustomerName := jsonConverter.getFileIdTextAsText(JToken.AsObject(), 'CustomerName');
        TubberwareCustomer.CustomerID := IdValue;
        TubberwareCustomer.CustomerName := CustomerName;
        TubberwareCustomer.CustomerMail := Mail;
        TubberwareCustomer.Insert();
        result := true;
    end;

}
