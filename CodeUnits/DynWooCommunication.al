//Communication to WooCommerce
codeunit 50203 ToWoocommerce
{
    //Item ID as parameter
    procedure ProcessCreateItem(ID: Code[20])
    var
        ItemTable: Record Item;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        contentHeaders: HttpHeaders;
        WooCommerceID: Code[20];
        JsonBody: JsonObject;
        sender: Text;
        AuthString: Text;
        ResponseText: Text;
        jsonResponse: JsonObject;
        jsonConverter: Codeunit JsonConverter;
        ItemID: Text;
        DockerIP: Text;
        TypeHelper: Codeunit "Base64 Convert"; //Converts text from Base64
        ck: Text;
        cs: Text;
        Category: JsonArray;
        Image: JsonArray;
    begin


        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        AuthString := StrSubstNo('%1:%2', ck, cs);

        //Encode the keys to Base64
        AuthString := TypeHelper.ToBase64(AuthString);

        //Add Basic %1 to the beginning of Auth
        //The 1% is a placeholder, it will be replaced by Auth at runtime
        AuthString := StrSubstNo('Basic 1%', AuthString);

        //Retriveves information about item from Item table using Item ID
        ItemTable.SetFilter("No.", ItemID);
        ItemTable.FindFirst();

        if (ItemTable.WooCommerceID = '') then begin

            ItemTable.CalcFields(Inventory);
            //Populate JsonObject with items name, price, description and Stock
            JsonBody.Add('name', ItemTable.Description);//Description
            JsonBody.Add('regular_price', Format(ItemTable."Unit Price"));//Unit_Price
            JsonBody.Add('description', ItemTable.ItemDescription);//Item_Description
            JsonBody.Add('short_description', ItemTable.ItemDescription);
            JsonBody.Add('manage_stock', true);//Inventory_Management
            JsonBody.Add('stock_quantity', Format(ItemTable.Inventory));//Inventory
            //jsonObject.Add('WooCommerce_ID', Format(ItemTable.WooCommerceID));
            //jsonObject.Add('Unit_Measure', ItemTable."Base Unit of Measure");
            JsonBody.WriteTo(sender);
            Content.WriteFrom(sender);
            Content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');
            client.DefaultRequestHeaders.Add('Authorization', AuthString);

            //HTTP POST request to WooCommerce API to create new product
            //Json object contains item details in request body
            DockerIP := '172.25.169.148:80'; //Change this to YOUR Docker IP
            Client.Post('http://' + DockerIP + '/wordpress/wp-json/wc/v2/products', Content, Response);

            //Extract ID of newly created Item from Response from WooCommerce API
            Response.Content.ReadAs(ResponseText);

            //Reads JSON data from ResponseText and stores it as Json Object
            jsonResponse.ReadFrom(ResponseText);

            //Stores the extracted ID as WooCommerceID in Item Table
            ItemTable.WooCommerceID := jsonConverter.getFileIdTextAsText(jsonResponse, 'id');
            //Save table with new ID
            ItemTable.Modify();

        end
        else begin
            Message('Item already exists');
        end;
    end;

    procedure ProcessUpdateItemStock(ID: Code[20])
    var
        ItemTable: Record Item;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        contentHeaders: HttpHeaders;
        JsonBody: JsonObject;
        ItemID: Text;
        AuthString: Text;
        Sender: Text;
        DockerIP: Text;
        TypeHelper: Codeunit "Base64 Convert"; //Converts text from Base64
        ck: Text;
        cs: Text;
    begin
        DockerIP := '172.25.169.148:80'; //Change this to YOUR Docker IP

        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        AuthString := StrSubstNo('%1:%2', ck, cs);

        //Encode the keys to Base64
        AuthString := TypeHelper.ToBase64(AuthString);

        //Add Basic %1 to the beginning of Auth
        //The 1% is a placeholder, it will be replaced by Auth at runtime
        AuthString := StrSubstNo('Basic 1%', AuthString);

        //Info about item with the specific ID
        ItemTable.SetFilter("No.", ID);
        ItemTable.FindFirst();
        ItemID := ItemTable.WooCommerceID;
        ItemTable.CalcFields(Inventory);

        //Add key value pair to JsonBody to be sent in POST to update Stock quantity
        //Key is 'Stock', the value is current Inventory of the Item inside the table
        JsonBody.Add('name', ItemTable.Description);//Description
        JsonBody.Add('regular_price', Format(ItemTable."Unit Price"));//Unit_Price
        JsonBody.Add('description', ItemTable.ItemDescription);//Item_Description
        JsonBody.Add('short_description', true);//Inventory_Management
        JsonBody.Add('stock_quantity', Format(ItemTable.Inventory));//Inventory

        //Writes JsonBody to the Sender as a Json String
        JsonBody.WriteTo(Sender);

        //Writes content of Sender to the Content as a byte stream
        Content.WriteFrom(Sender);

        //Retrieves headers for content and stores them in contentHeaders
        Content.GetHeaders(contentHeaders);
        contentHeaders.Clear();

        //New header to contentHeaders, specifies POST is in JSON format
        contentHeaders.Add('Content-Type', 'application/json');

        //Auth header with Base64 encoded login for Woo REST API
        Client.DefaultRequestHeaders.Add('Authorization', AuthString);

        //POST request to Woo REST API to update stock of item(ID)
        //Content is to send data, Content to receive data for request
        Client.Post('http://' + DockerIP + '/wordpress/wp-json/wc/v2/products/' + ItemID, Content, Response);

    end;

}


//Communication from WooCommerce
codeunit 50204 FromWoocommerce
{
    //Unfinished, finish it
    procedure ProcessCreateCustomer(Res: Text) result: Boolean
    var
        CustomerTable: Record Customer;
        Email: Codeunit EmailController;
        Json: Codeunit JsonConverter;
        JsonBody: JsonObject;
        BillingJsonToken: JsonToken;
        stringSplit: List of [Text];
        endingTxt: Text;
    begin
        //The payload has alot of extra symbols, as seen from tests, will make it easier to remove them
        //{"Payload":{\r\n  \"id\": 72,\r\n  \"parent_id\": 0,\r\n  \"status\": \"processing\",\r\n}}
        Res := Res.Replace('\r\n', '');
        Res := Res.Replace('\', '');
        stringSplit := Res.Split('avatar_url');
        endingTxt := DelChr(stringSplit.Get(1), '>', ', "');
        JsonBody.ReadFrom(endingTxt + '}');
        CustomerTable.SetFilter("No.", Json.getFileIdTextAsText(JsonBody, 'id'));

        if not CustomerTable.FindSet() then begin
            CustomerTable.Init();
            CustomerTable."No." := Json.getFileIdTextAsText(JsonBody, 'id');//ID
            CustomerTable."E-Mail" := Json.getFileIdTextAsText(JsonBody, 'email');//Email
            //CustomerTable.Name := Json.getFileIdTextAsText(JsonBody, 'first_name');//FirstName
            CustomerTable.Name := Json.getFileIdTextAsText(JsonBody, 'first_name') + ' ' + Json.getFileIdTextAsText(JsonBody, 'last_name');//LastName

            JsonBody.Get('Billing', BillingJsonToken);
            CustomerTable.Address := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'address_1');//Address
            CustomerTable.County := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'country');//Country
            CustomerTable."Post Code" := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'postcode');//Postcode
            CustomerTable.City := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'city');//City
            CustomerTable."Phone No." := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'phone');//Phone
            CustomerTable."Payment Method Code" := 'KONTANT';
            CustomerTable."Gen. Bus. Posting Group" := 'EU';
            CustomerTable."Customer Posting Group" := 'EU';

            CustomerTable.Insert();
            CustomerTable.SetFilter("No.", Json.getFileIdTextAsText(JsonBody, 'id'));
            CustomerTable.FindFirst();
            Email.NewCustomerEmail(CustomerTable."No.");
        end else begin
            CustomerTable.SetFilter("No.", Json.getFileIdTextAsText(JsonBody, 'id'));
            CustomerTable.FindFirst();
            CustomerTable."E-Mail" := Json.getFileIdTextAsText(JsonBody, 'email');
            CustomerTable.Name := Json.getFileIdTextAsText(JsonBody, 'first_name') + ' ' + Json.getFileIdTextAsText(JsonBody, 'LastName');

            JsonBody.Get('billing', BillingJsonToken);
            CustomerTable.Address := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'address_1');
            CustomerTable.County := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'country');
            CustomerTable."Post Code" := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'postcode');
            CustomerTable.City := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'city');
            CustomerTable."Phone No." := Json.getFileIdTextAsText(BillingJsonToken.AsObject(), 'phone');
            CustomerTable."Payment Method Code" := 'KONTANT';
            CustomerTable."Gen. Bus. Posting Group" := 'EU';
            CustomerTable."Customer Posting Group" := 'EU';

            CustomerTable.Modify();
        end;
        result := true;

        //Add welcome mail somewhere around the end here
    end;

    //Unfinished, finish it
    procedure ProcessCreateSalesOrder(Res: Text)


}


