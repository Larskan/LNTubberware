//Experiment, remove if I end up not using it
codeunit 50206 WooCommerceConnector
{
    procedure GetProducts()
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseTxt: Text;
        Products: JsonArray;
        Product: JsonObject;
        T: JsonToken;
        NameField: JsonToken;
        ck: Text;
        cs: Text;
    begin
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        Request.Method := 'GET';
        Request.SetRequestUri('http://localhost/wordpress/wp-json/wc/v3/products?consumer_key=' + ck + '&consumer_secret=' + cs);

        if Client.Send(Request, Response) then begin
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseTxt);
                Products.ReadFrom(ResponseTxt);
                foreach T in Products do begin
                    Product := T.AsObject();
                    Product.Get('First name', NameField);
                    Message('%1', NameField.AsValue().AsText());
                end;
            end else
                error('We got %1 problems', Response.HttpStatusCode());
        end else
            Error('We got a problem');
    end;
}