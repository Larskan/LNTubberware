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
        authString: Text;
        ResponseText: Text;
        jsonResponse: JsonObject;
        jsonConverter: Codeunit JsonConverter;
        //ItemID: Text;
        MyPCIP: Text;
        TypeHelper: Codeunit "Base64 Convert"; //Converts text from Base64
        ck: Text;
        cs: Text;
    begin


        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        authString := StrSubstNo('%1:%2', ck, cs);
        //authString := StrSubstNo('ck_85a060bf066868da1c40742290aaf79986798d71:cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb');

        //Encode the keys to Base64
        authString := TypeHelper.ToBase64(authString);

        //Add Basic %1 to the beginning of Auth
        //The 1% is a placeholder, it will be replaced by Auth at runtime
        authString := StrSubstNo('Basic %1', authString); //REMEMBER % FIRST

        //Retriveves information about item from Item table using Item ID
        ItemTable.SetFilter("No.", ID);
        ItemTable.FindFirst();

        if (ItemTable.WooCommerceID = '') then begin

            ItemTable.CalcFields(Inventory);
            //Populate JsonObject with items name, price, description and Stock
            JsonBody.Add('name', ItemTable.Description);
            JsonBody.Add('regular_price', Format(ItemTable."Unit Price"));
            JsonBody.Add('description', ItemTable.ItemDescription);
            JsonBody.Add('manage_stock', true);
            JsonBody.Add('stock_quantity', Format(ItemTable.Inventory));
            JsonBody.WriteTo(sender);
            Content.WriteFrom(sender);
            Content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');
            client.DefaultRequestHeaders.Add('Authorization', authString);

            //HTTP POST request to WooCommerce API to create new product
            //Json object contains item details in request body
            MyPCIP := '172.25.160.1:80'; //Change this to YOUR Docker IP

            //http://172.25.160.1:80/wordpress/wp-json/wc/v2/products
            //IP: PC IP?172.25.160.1
            Client.Post('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products', Content, Response);

            //Extract ID of newly created Item from Response from WooCommerce API
            Response.Content.ReadAs(ResponseText); //String and Json issues?

            Message('Response Lars: ' + ResponseText);

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
        MyPCIP: Text;
        TypeHelper: Codeunit "Base64 Convert"; //Converts text from Base64
        ck: Text;
        cs: Text;
    begin
        MyPCIP := '172.25.160.1:80'; //Change this to YOUR Docker IP

        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        AuthString := StrSubstNo('%1:%2', ck, cs);

        //Encode the keys to Base64
        AuthString := TypeHelper.ToBase64(AuthString);

        //Add Basic %1 to the beginning of Auth
        //The 1% is a placeholder, it will be replaced by Auth at runtime
        AuthString := StrSubstNo('Basic %1', AuthString);

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
        Client.Post('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products/' + ItemID, Content, Response);

    end;

}


//Communication from WooCommerce
codeunit 50204 FromWoocommerce
{
    /*
    Customer:
      email*
      first_name*
      last_name*
      username
    billing
      first_name*
      last_name*
      company
      address_1*
      address_2
      city*
      state
      postcode*
      country/County*
      email*
      phone*
    shipping - Skip this
      first_name
      last_name
      company
      address_1
      address_2
      city
      state
      postcode
      country
    */

    //Its important that the payload:Text has the same name as the public string within your Payload Class in API
    procedure ProcessCreateCustomer(payload: Text) result: Boolean
    var
        CustomerTable: Record Customer;
        Email: Codeunit EmailDefinition;
        JsonConverter: Codeunit JsonConverter;
        JsonBody: JsonObject;
        BillingJsonText: JsonToken;
        stringSplit: list of [text];
        endtext: Text;
    begin
        //Note to self: keep lowercase in strings and notice the %/# if I use them.
        //The payload has alot of extra symbols, as seen from tests, will make it easier to read if we remove them
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        stringSplit := payload.Split('avatar_url');
        //'>' means you check if something exists beyond it. 
        //Like if ', "' exists at the end then you use the DeleteCharacter(DelChr)
        //Get(1) grabs the (0), since dynamics starts from 1
        endtext := DelChr(stringSplit.Get(1), '>', ', "');
        //Adds the closing at the end, to make sure its valid syntax
        JsonBody.ReadFrom(endtext + '}');

        //Match No. with the id
        CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(JsonBody, 'id'));

        //If I cant find my Customer, it means they are new: Create them
        if not CustomerTable.FindSet() then begin
            CustomerTable.Init();
            CustomerTable."No." := JsonConverter.getFileIdTextAsText(JsonBody, 'id');
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(JsonBody, 'email');
            CustomerTable.Name := JsonConverter.getFileIdTextAsText(JsonBody, 'first_name');
            CustomerTable."Name 2" := JsonConverter.getFileIdTextAsText(JsonBody, 'last_name');


            JsonBody.Get('billing', BillingJsonText);
            CustomerTable.Address := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'address_1');
            CustomerTable.City := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'city');
            CustomerTable."Post Code" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'postcode');
            CustomerTable.County := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'country'); //County is also a Country
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'email');
            CustomerTable."Phone No." := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'phone');
            CustomerTable.Insert();

            //Once inserted, now I can find them and send the welcome mail
            CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(JsonBody, 'id'));
            CustomerTable.FindFirst();
            Email.NewCustomerEmail(CustomerTable."No.");

            //Existing Customer
        end else begin
            CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(JsonBody, 'id'));
            CustomerTable.FindFirst();
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(JsonBody, 'email');
            CustomerTable.Name := JsonConverter.getFileIdTextAsText(JsonBody, 'first_name');
            CustomerTable."Name 2" := JsonConverter.getFileIdTextAsText(JsonBody, 'last_name');

            JsonBody.Get('billing', BillingJsonText);
            CustomerTable.Address := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'address_1');
            CustomerTable.City := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'city');
            CustomerTable."Post Code" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'postcode');
            CustomerTable.County := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'country');
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'email');
            CustomerTable."Phone No." := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'phone');

            CustomerTable.Modify();
        end;
        result := true;

    end;

    //Unfinished, finish it
    procedure ProcessCreateSalesOrder(payload: Text)
    var
        SalesHeaderRecord: Record "Sales Header"; //For the Customer
        SalesLineRecord: Record "Sales Line";
        CustomerTable: Record Customer;
        ItemTable: Record Item;
        Email: Codeunit EmailDefinition;
        JsonConverter: Codeunit JsonConverter;
        JsonBody: JsonObject;
        CostJsonToken: JsonToken;
        JsonArrayItem: JsonArray;
        ArrayToken: JsonToken;
        OrderID: Integer;
        CustomerID: Text;
        TypeDate: Date;
        OrderDate: Text;
        endingTxt: Text;
        valueQuantity: Decimal;
        Subtotal: Decimal;
        WooCommerceIDTemporary: Code[20];
        Counter: Integer;
        stringSplit: List of [Text];
    begin
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        stringSplit := payload.Split('avatar_url');
        endingTxt := DelChr(stringSplit.Get(1), '>', '"}}. "');
        JsonBody.ReadFrom(endingTxt + '}');

        JsonBody.Get('billing', CostJsonToken);

        SalesHeaderRecord.Init();
        SalesHeaderRecord."Document Type" := "Sales Document Type".FromInteger(1);
        SalesHeaderRecord."No." := JsonConverter.getFileIdTextAsText(JsonBody, 'id');
        CustomerID := JsonConverter.getFileIdTextAsText(JsonBody, 'customer_id');
        CustomerTable.SetFilter("No.", CustomerID);
        CustomerTable.FindFirst();
        SalesHeaderRecord."Bill-to Name" := CustomerTable.Name;
        SalesHeaderRecord."Bill-to Customer No." := CustomerTable."No.";
        SalesHeaderRecord."Bill-to Name" := CustomerTable.Name;
        SalesHeaderRecord."Bill-to Address" := CustomerTable.Address;
        SalesHeaderRecord."Bill-to City" := CustomerTable.City;
        SalesHeaderRecord."Bill-to Post Code" := CustomerTable."Post Code";

        SalesHeaderRecord."Sell-to Customer No." := CustomerTable."No.";
        SalesHeaderRecord."Sell-to Customer Name" := CustomerTable.Name;
        SalesHeaderRecord."Sell-to Address" := CustomerTable.Address;
        SalesHeaderRecord."Sell-to City" := CustomerTable.City;
        SalesHeaderRecord."Sell-to E-Mail" := CustomerTable."E-Mail";
        SalesHeaderRecord."Sell-to Phone No." := CustomerTable."Phone No.";

        SalesHeaderRecord."Ship-to Name" := JsonConverter.getFileIdTextAsText(CostJsonToken.AsObject(), 'first_name');
        SalesHeaderRecord."Ship-to Address" := JsonConverter.getFileIdTextAsText(CostJsonToken.AsObject(), 'address_1');
        SalesHeaderRecord."Ship-to City" := JsonConverter.getFileIdTextAsText(CostJsonToken.AsObject(), 'city');
        SalesHeaderRecord."Ship-to Post Code" := JsonConverter.getFileIdTextAsText(CostJsonToken.AsObject(), 'postcode');

        OrderDate := JsonConverter.getFileIdTextAsText(JsonBody, 'date_created');
        OrderDate := CopyStr(OrderDate, 9, 2) + CopyStr(OrderDate, 6, 2) + CopyStr(OrderDate, 1, 4);
        Evaluate(TypeDate, '13-05-2023');

        SalesHeaderRecord."Order Date" := TypeDate;
        SalesHeaderRecord."Posting Date" := TypeDate;
        SalesHeaderRecord."Shipment Date" := TypeDate;

        SalesHeaderRecord."Payment Method Code" := 'KONTANT';
        SalesHeaderRecord.Status := "Sales Document Status".FromInteger(0);
        SalesHeaderRecord.Insert();

        JsonArrayItem := JsonConverter.getFileIdTextAsJSArray(JsonBody, 'line_items');
        Counter := 1;
        foreach Arraytoken in JsonArrayItem do begin
            SalesLineRecord.Init();
            SalesLineRecord."Document Type" := "Sales Document Type".FromInteger(1);
            SalesLineRecord."Document No." := SalesHeaderRecord."No."; //note

            SalesLineRecord.Type := "Sales Line Type".FromInteger(2);
            SalesLineRecord."Line No." := Counter;
            WooCommerceIDTemporary := JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'product_id');
            ItemTable.SetFilter(WoocommerceId, WooCommerceIDTemporary);
            ItemTable.FindFirst();
            SalesLineRecord."No." := ItemTable."No.";
            Evaluate(valueQuantity, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'quantity'));
            SalesLineRecord.Quantity := valueQuantity;
            SalesLineRecord."Unit of Measure" := 'STK';
            SalesLineRecord."Qty. to Ship" := valueQuantity;
            SalesLineRecord."Qty. to Invoice" := valueQuantity;
            SalesLineRecord."Sell-to Customer No." := CustomerTable."No.";
            SalesLineRecord.Description := ItemTable.Description;
            SalesLineRecord."Unit Price" := ItemTable."Unit Price";
            Evaluate(Subtotal, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'subtotal'));
            SalesLineRecord."Line Amount" := Subtotal;
            SalesLineRecord.Insert();

            Counter += 1;
        end;
        Email.NewOrderEmail(SalesHeaderRecord."No.");
    end;

}


