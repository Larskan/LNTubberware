//Communication to WooCommerce
codeunit 50203 ToWoocommerce
{
    //Item ID as parameter
    procedure ProcessCreateItem(itemId: Code[20])
    var
        ItemTable: Record Item;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        contentHeaders: HttpHeaders;
        MainJson: JsonObject;
        jsonObjResponse: JsonObject;
        category: JsonArray;
        image: JsonArray;
        sender: Text;
        jsonConverter: Codeunit JsonConverter;
        TypeHelper: Codeunit "Base64 Convert"; //Converts text from Base64
        authString: Text;
        ResponseText: Text;
        WooId: Code[20];
        MyPCIP: Text;
        ck: Text;
        cs: Text;
    begin


        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        authString := StrSubstNo('%1:%2', ck, cs);
        //authString := StrSubstNo('ck_85a060bf066868da1c40742290aaf79986798d71:cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb');
        authString := TypeHelper.ToBase64(authString);
        authString := StrSubstNo('Basic %1', authString);

        //Retriveves information about item from Item table using Item ID
        ItemTable.SetFilter("No.", itemId);
        ItemTable.FindFirst();

        if (ItemTable.WooCommerceId = '') then begin

            ItemTable.CalcFields(Inventory);
            MainJson.Add('name', ItemTable.Description);
            MainJson.Add('regular_price', Format(ItemTable."Unit Price"));
            MainJson.Add('description', ItemTable.ItemDescription);
            MainJson.Add('manage_stock', true);
            MainJson.Add('stock_quantity', Format(ItemTable.Inventory));
            //MainJson.Add('physical_web', Format(ItemTable.PhysicalOrWebshop)); //For location
            MainJson.WriteTo(sender);

            Content.WriteFrom(sender);
            Content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');
            client.DefaultRequestHeaders.Add('Authorization', authString);
            MyPCIP := '172.25.160.1:80'; //Change this to YOUR PC IP

            //http://172.25.160.1:80/wordpress/wp-json/wc/v2/products
            //IP: PC IP?172.25.160.1
            Client.Post('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products', Content, Response);

            //Extract ID of newly created Item from Response from WooCommerce API
            Response.Content.ReadAs(ResponseText); //String and Json issues?
            //Reads JSON data from ResponseText and stores it as Json Object
            jsonObjResponse.ReadFrom(ResponseText);

            //Stores the extracted ID as WooCommerceID in Item Table
            ItemTable.WooCommerceId := jsonConverter.getFileIdTextAsText(jsonObjResponse, 'id');
            //Save table with new ID
            ItemTable.Modify();
        end
        else begin
            Message('Item already exists, use update instead');
        end;
    end;

    //Works
    procedure ProcessUpdateItemStock(itemId: Code[20])
    var
        ItemTable: Record Item;
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        contentHeaders: HttpHeaders;
        TypeHelper: Codeunit "Base64 Convert";
        MainJson: JsonObject;
        AuthString: Text;
        Sender: Text;
        MyPCIP: Text;
        ck: Text;
        cs: Text;
    begin
        MyPCIP := '172.25.160.1:80'; //Change this to YOUR Ipv4 IP : xampp Port
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        AuthString := StrSubstNo('%1:%2', ck, cs);
        AuthString := TypeHelper.ToBase64(AuthString);
        AuthString := StrSubstNo('Basic %1', AuthString);

        //Select the item depending on itemId
        ItemTable.SetFilter("No.", itemId);
        ItemTable.FindFirst();

        itemId := ItemTable.WooCommerceId;
        ItemTable.CalcFields(Inventory);
        MainJson.Add('manage_stock', true);
        MainJson.Add('stock_quantity', Format(ItemTable.Inventory));
        MainJson.WriteTo(sender);

        Content.WriteFrom(sender);
        Content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        client.DefaultRequestHeaders.Add('Authorization', authString);
        Client.Put('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products/' + itemId, Content, Response);
    end;

}

//Communication from WooCommerce
codeunit 50204 FromWoocommerce
{
    //Its important that the payload:Text has the same name as the public string within your Payload Class in API
    procedure ProcessCreateCustomer(payload: Text) result: Boolean
    var
        CustomerTable: Record Customer;
        Email: Codeunit EmailDefinition;
        JsonConverter: Codeunit JsonConverter;
        MainJson: JsonObject;
        BillingJsonText: JsonToken;
        stringSplit: list of [text];
        endtext: Text;
    begin
        //The payload has alot of extra symbols, as seen from tests, will make it easier to read if we remove them
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        stringSplit := payload.Split('avatar_url');
        //'>' means you check if something exists beyond it. 
        //Like if ', "' exists at the end then you use the DeleteCharacter(DelChr)
        //Get(1) grabs the (0), since dynamics starts from 1
        endtext := DelChr(stringSplit.Get(1), '>', ', "');
        //Adds the closing at the end, to make sure its valid syntax
        MainJson.ReadFrom(endtext + '}');
        CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(MainJson, 'id'));

        //If I cant find my Customer, it means they are new: Create them
        if not CustomerTable.FindSet() then begin
            CustomerTable.Init();
            CustomerTable."No." := JsonConverter.getFileIdTextAsText(MainJson, 'id');
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(MainJson, 'email');
            CustomerTable.Name := JsonConverter.getFileIdTextAsText(MainJson, 'first_name') + ' ' + JsonConverter.getFileIdTextAsText(MainJson, 'last_name');

            MainJson.Get('billing', BillingJsonText);
            CustomerTable.Address := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'address_1');
            CustomerTable.County := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'country'); //County is also a Country
            CustomerTable."Post Code" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'postcode');
            CustomerTable.City := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'city');
            CustomerTable."Phone No." := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'phone');

            CustomerTable."Payment Method Code" := 'KONTANT';
            CustomerTable."Gen. Bus. Posting Group" := 'EU';
            CustomerTable."Customer Posting Group" := 'EU';

            CustomerTable.Insert();

            //Once inserted, now I can find them and send the welcome mail
            //Filter the No. based on the matching id of the customer, then send the mail to that customer
            CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(MainJson, 'id'));
            CustomerTable.FindFirst();
            Email.NewCustomerEmail(CustomerTable."No.");

            //Existing Customer
        end else begin
            CustomerTable.SetFilter("No.", JsonConverter.getFileIdTextAsText(MainJson, 'id'));
            CustomerTable.FindFirst();
            CustomerTable."E-Mail" := JsonConverter.getFileIdTextAsText(MainJson, 'email');
            CustomerTable.Name := JsonConverter.getFileIdTextAsText(MainJson, 'first_name') + ' ' + JsonConverter.getFileIdTextAsText(MainJson, 'last_name');

            MainJson.Get('billing', BillingJsonText);
            CustomerTable.Address := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'address_1');
            CustomerTable.County := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'country');
            CustomerTable."Post Code" := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'postcode');
            CustomerTable.City := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'city');
            CustomerTable."Phone No." := JsonConverter.getFileIdTextAsText(BillingJsonText.AsObject(), 'phone');

            CustomerTable."Payment Method Code" := 'KONTANT';
            CustomerTable."Gen. Bus. Posting Group" := 'EU';
            CustomerTable."Customer Posting Group" := 'EU';

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
        MainJson: JsonObject;
        CostJsonToken: JsonToken;
        ShipJsonToken: JsonToken;
        JsonArrayItem: JsonArray;
        ArrayToken: JsonToken;
        OrderId: Integer;
        CustomerId: Text;
        TypeDate: Date;
        OrderDate: Text;
        endingTxt: Text;
        ValueQuantity: Decimal;
        Subtotal: Decimal;
        wooCommerceIDTemporary: Code[20];
        counter: Integer;
        stringSplit: List of [Text];
    begin
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        stringSplit := payload.Split('avatar_url');
        endingTxt := DelChr(stringSplit.Get(1), '>', '"}}. "');
        MainJson.ReadFrom(endingTxt + '}');

        MainJson.Get('billing', CostJsonToken);

        SalesHeaderRecord.Init();
        SalesHeaderRecord."Document Type" := "Sales Document Type".FromInteger(1);
        SalesHeaderRecord."No." := JsonConverter.getFileIdTextAsText(MainJson, 'id');
        CustomerId := JsonConverter.getFileIdTextAsText(MainJson, 'customer_id');
        CustomerTable.SetFilter("No.", CustomerId);
        CustomerTable.FindFirst();
        SalesHeaderRecord."Bill-to Name" := CustomerTable.Name;
        SalesHeaderRecord."Bill-to Customer No." := CustomerTable."No.";
        SalesHeaderRecord."Bill-to Name" := CustomerTable."Name";
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

        OrderDate := JsonConverter.getFileIdTextAsText(MainJson, 'date_created');
        OrderDate := CopyStr(OrderDate, 9, 2) + CopyStr(OrderDate, 6, 2) + CopyStr(OrderDate, 1, 4);
        Evaluate(TypeDate, '01-01-2023');

        SalesHeaderRecord."Order Date" := TypeDate;
        SalesHeaderRecord."Posting Date" := TypeDate;
        SalesHeaderRecord."Shipment Date" := TypeDate;

        SalesHeaderRecord."Payment Method Code" := 'KONTANT';
        SalesHeaderRecord.Status := "Sales Document Status".FromInteger(0);
        SalesHeaderRecord.Insert();

        JsonArrayItem := JsonConverter.getFileIdTextAsJSArray(MainJson, 'line_items');
        counter := 1;
        foreach ArrayToken in JsonArrayItem do begin
            SalesLineRecord.Init();
            SalesLineRecord."Document Type" := "Sales Document Type".FromInteger(1);
            SalesLineRecord."Document No." := SalesHeaderRecord."No."; //note

            SalesLineRecord.Type := "Sales Line Type".FromInteger(2);
            SalesLineRecord."Line No." := counter;
            wooCommerceIDTemporary := JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'product_id');
            ItemTable.SetFilter(WooCommerceId, wooCommerceIDTemporary);
            ItemTable.FindFirst();
            SalesLineRecord."No." := ItemTable."No.";
            Evaluate(ValueQuantity, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'quantity'));
            SalesLineRecord.Quantity := ValueQuantity;
            SalesLineRecord."Unit of Measure" := 'STK';
            SalesLineRecord."Qty. to Ship" := ValueQuantity;
            SalesLineRecord."Qty. to Invoice" := ValueQuantity;
            SalesLineRecord."Sell-to Customer No." := CustomerTable."No.";
            SalesLineRecord.Description := ItemTable.Description;
            SalesLineRecord."Unit Price" := ItemTable."Unit Price";
            Evaluate(Subtotal, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'subtotal'));
            SalesLineRecord."Line Amount" := Subtotal;
            SalesLineRecord.Insert();

            counter += 1;
        end;
        Email.NewOrderEmail(SalesHeaderRecord."No.");
    end;

}


