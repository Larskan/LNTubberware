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


}


