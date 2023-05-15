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
        MainJson: JsonObject; //Store JSON to be sent to HTTP request
        jsonObjResponse: JsonObject; //Store JSON response from WooCommerce API
        category: JsonArray; //Store categories of the item
        image: JsonArray; //Store image of item
        sender: Text; //Store JSON data as string
        jsonConverter: Codeunit JsonConverter;
        TypeHelper: Codeunit "Base64 Convert"; //Encode in base64
        authString: Text; //Store the encoded
        ResponseText: Text; //Store response content
        WooId: Code[20]; //Store WooCommerce ID of new item
        MyPCIP: Text; //My PC IP
        ck: Text; //Consumer Key
        cs: Text; //Consumer Secret
    begin
        //Linking the consumer key and consumer secret together
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        //StrSubstNo replaces % or # values with the key values
        authString := StrSubstNo('%1:%2', ck, cs);
        authString := TypeHelper.ToBase64(authString); //Encodes to Base64 which is needed for HTTP Basic Auth
        authString := StrSubstNo('Basic %1', authString);

        //Filter for matching No. from ItemTable with itemId parameter
        ItemTable.SetFilter("No.", itemId);
        ItemTable.FindFirst();

        //Check if the WooCommerceId for the item is empty and create it if it is
        if (ItemTable.WooCommerceId = '') then begin

            ItemTable.CalcFields(Inventory); //Calcs value of Inventory in ItemTable
            //Populate the item
            MainJson.Add('name', ItemTable.Description);
            MainJson.Add('regular_price', Format(ItemTable."Unit Price"));
            MainJson.Add('description', ItemTable.ItemDescription);
            MainJson.Add('manage_stock', true);
            MainJson.Add('stock_quantity', Format(ItemTable.Inventory));
            //Write MainJson to sender as a JSON string
            MainJson.WriteTo(sender);
            //Writes content of sender to Content
            Content.WriteFrom(sender);
            Content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');
            client.DefaultRequestHeaders.Add('Authorization', authString);
            MyPCIP := '172.25.160.1:80'; //Change this to YOUR PC IP

            //POST request to WooCommerce, Content is JSON payload, Response is response from API
            Client.Post('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products', Content, Response);

            //Read conttent of Response and store it as a string
            Response.Content.ReadAs(ResponseText);
            //Parses the JSON data in ResponseText and stores it as JSON Object
            jsonObjResponse.ReadFrom(ResponseText);

            //Get 'id' from the key in jsonObject, then assign that id to WooCommerceId in ItemTable
            ItemTable.WooCommerceId := jsonConverter.getFileIdTextAsText(jsonObjResponse, 'id');
            ItemTable.Modify();
        end
        else begin
            Message('Item already exists');
        end;
    end;

    //Works
    procedure ProcessUpdateItemStock(itemId: Code[20])
    var
        ItemTable: Record Item;
        Client: HttpClient; //Instance for HTTP requests
        Response: HttpResponseMessage;
        Content: HttpContent; //Holds content of HTTP request or response
        contentHeaders: HttpHeaders; //Used to manipulate headers of an HTTP request or response
        TypeHelper: Codeunit "Base64 Convert"; //Encoding and decoding base64 strings
        MainJson: JsonObject; //Hold JSON data
        AuthString: Text; //Hold encoded authentication string
        Sender: Text; //Hold a string representation of MainJson
        MyPCIP: Text; //IP Address of the server running Wordpress(Localhost)
        ck: Text; //Consumer Key
        cs: Text; //Consumer Secret
    begin
        MyPCIP := '172.25.160.1:80'; //Change this to YOUR Ipv4 IP : xampp Port
        ck := 'ck_85a060bf066868da1c40742290aaf79986798d71';
        cs := 'cs_1c1aa151473eaaf6d085c48a0e30831abfd405cb';
        AuthString := StrSubstNo('%1:%2', ck, cs);
        AuthString := TypeHelper.ToBase64(AuthString); //Encode to base64
        //Using Basic authentication
        AuthString := StrSubstNo('Basic %1', AuthString);

        //Filter the ItemTable to find first record with No. matching our itemId parameter
        ItemTable.SetFilter("No.", itemId);
        ItemTable.FindFirst();

        itemId := ItemTable.WooCommerceId;
        //Inventory of ItemTable is calculated and added to MainJson as stock_quantity
        ItemTable.CalcFields(Inventory);
        MainJson.Add('manage_stock', true);
        MainJson.Add('stock_quantity', Format(ItemTable.Inventory));
        //Write MainJson to sender as a JSON string
        MainJson.WriteTo(sender);
        //Writes content of sender to Content
        Content.WriteFrom(sender);
        Content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        //Add new header to specify that this is JSON
        contentHeaders.Add('Content-Type', 'application/json');
        //Authorization header to default request header, includes our encoded credentials
        client.DefaultRequestHeaders.Add('Authorization', authString);
        //Update stock_quantity of WooCommerce product with the itemId parameter
        Client.Put('http://' + MyPCIP + '/wordpress/wp-json/wc/v2/products/' + itemId, Content, Response);
    end;

}

//Communication from WooCommerce
codeunit 50204 FromWoocommerce
{
    //If Customer is created in WooCommerce, it also creates the Customer in Dynamics and sends Welcome Email
    procedure ProcessCreateCustomer(payload: Text) result: Boolean
    var
        CustomerTable: Record Customer; //Customer info
        Email: Codeunit EmailDefinition; //Default emails
        JsonConverter: Codeunit JsonConverter; //Convert JSON to AL data
        MainJson: JsonObject; //Stored the main JSON
        BillingJsonText: JsonToken; //
        stringSplit: list of [text];
        endtext: Text;
    begin
        //Replace \r\n and \ with an empty string to ensure payload string is properly formatted for parsing as JSON
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        //Splits payload into list of text values based on 'avatar_url'
        stringSplit := payload.Split('avatar_url');
        //Takes the 2nd value from the splitted list 
        //and removes any trailing text after the first '>' char and before the final ', "' chars
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

    //If an Order is created in WooCommerce, it creates a Sales Order in Dynamics and sends Confirmation Email
    procedure ProcessCreateSalesOrder(payload: Text)
    var
        SalesHeaderRecord: Record "Sales Header"; //header information for a sales order
        SalesLineRecord: Record "Sales Line"; //Line items for a sales order
        CustomerTable: Record Customer; //Customer information
        ItemTable: Record Item; //Item information
        Email: Codeunit EmailDefinition; //Default Emails
        JsonConverter: Codeunit JsonConverter; //Convert JSON data to and from AL data types
        MainJson: JsonObject; //Holds main JSON object from the payload
        CostJsonToken: JsonToken; //Holds the JSON object for billing information in the payload
        JsonArrayItem: JsonArray; //Holds the JSON array of line items in the payload
        ArrayToken: JsonToken; //Holds a single JSON object from the line items array
        CustomerId: Text; //Customer ID from payload
        endingTxt: Text; //Holds end of payload string after some cleaning
        ValueQuantity: Decimal; //Holds decimal
        Subtotal: Decimal; //Holds the subtotal for a sales order line item
        wooCommerceIDTemporary: Code[20]; //Holds the temporary code for Woo ID
        counter: Integer; //Keeps track of the line item number
        stringSplit: List of [Text]; //Holds the results of splitting the payload string on avatar_url substring

    begin
        //Replace \r\n and \ with an empty string to ensure payload string is properly formatted for parsing as JSON
        payload := payload.Replace('\r\n', '');
        payload := payload.Replace('\', '');
        //Splits payload into list of text values based on 'avatar_url'
        stringSplit := payload.Split('avatar_url');
        //Takes the 2nd value from the splitted list 
        //and removes any trailing text after the first '>' char and before the final '}}"' chars
        endingTxt := DelChr(stringSplit.Get(1), '>', '"}}. "');
        //Add the closing braces for the JSON format
        MainJson.ReadFrom(endingTxt + '}}');

        //Gets billing within MainJson and stores it in CostJsonToken
        MainJson.Get('billing', CostJsonToken);

        //Initializes and populate the JSON data based on MainJson and CustomerTable
        SalesHeaderRecord.Init();
        //Set to Sales Document Type 1 = Sales Order
        SalesHeaderRecord."Document Type" := "Sales Document Type".FromInteger(1);
        //Set the No. field to id from MainJson, the 'id' is the id of order generated by WooCommerce
        SalesHeaderRecord."No." := JsonConverter.getFileIdTextAsText(MainJson, 'id');
        //Retrieve customer_id from MainJson and setup filter on CustomerTable based on customer_id
        CustomerId := JsonConverter.getFileIdTextAsText(MainJson, 'customer_id');
        CustomerTable.SetFilter("No.", CustomerId);
        //FindFirst: Moves the focus to the first record that matches the filter
        CustomerTable.FindFirst();
        //Set Bill-to and Sell-to customer fields to values that match CustomerTable
        SalesHeaderRecord."Bill-to Customer No." := CustomerTable."No.";
        SalesHeaderRecord."Bill-to Name" := CustomerTable.Name;
        SalesHeaderRecord."Sell-to Customer No." := CustomerTable."No.";
        SalesHeaderRecord."Sell-to Customer Name" := CustomerTable.Name;
        SalesHeaderRecord."Sell-to E-Mail" := CustomerTable."E-Mail";
        //Ships to first_name taken from CostJsonToken which was used to hold the billing information
        SalesHeaderRecord."Ship-to Name" := JsonConverter.getFileIdTextAsText(CostJsonToken.AsObject(), 'first_name');
        //Sales Document Status 0 = New
        SalesHeaderRecord.Status := "Sales Document Status".FromInteger(0);
        SalesHeaderRecord.Insert();

        //Once we got customer data and created sales order, we grab the line items from JSON payload
        //This will return a JSON array of objects with the line items in order
        JsonArrayItem := JsonConverter.getFileIdTextAsJSArray(MainJson, 'line_items');
        //counter: set the line number for each sales line record
        counter := 1;
        //foreach object in the line items array do the loop, creates new sales line for each item
        foreach ArrayToken in JsonArrayItem do begin
            SalesLineRecord.Init();
            SalesLineRecord."Document Type" := "Sales Document Type".FromInteger(1);
            SalesLineRecord."Document No." := SalesHeaderRecord."No."; //note
            SalesLineRecord.Type := "Sales Line Type".FromInteger(2);
            SalesLineRecord."Line No." := counter;
            //Get product_id for current line item
            wooCommerceIDTemporary := JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'product_id');
            //Filter: Find the matching id in WooCommerce that matches with product_id
            ItemTable.SetFilter(WooCommerceId, wooCommerceIDTemporary);
            ItemTable.FindFirst();
            //Set the fields of Sales Line Record
            SalesLineRecord."No." := ItemTable."No.";
            Evaluate(ValueQuantity, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'quantity'));
            SalesLineRecord.Quantity := ValueQuantity;
            SalesLineRecord."Unit of Measure" := 'STK';
            SalesLineRecord."Sell-to Customer No." := CustomerTable."No.";
            SalesLineRecord.Description := ItemTable.Description;
            SalesLineRecord."Unit Price" := ItemTable."Unit Price";
            Evaluate(Subtotal, JsonConverter.getFileIdTextAsText(ArrayToken.AsObject(), 'subtotal'));
            SalesLineRecord."Line Amount" := Subtotal;
            //Add the new sales to the Dynamics
            SalesLineRecord.Insert();

            counter += 1;
        end;
        Email.NewOrderEmail(SalesHeaderRecord."No.");
    end;
}


