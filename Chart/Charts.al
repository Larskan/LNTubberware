page 50340 "Chart"
{
    PageType = Card;
    Caption = 'Product Chart';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            usercontrol(Chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger DataPointClicked(point: JsonObject)
                var
                    DataJsonTxt: Text;
                    ProductTable: Record "CRM Product";
                    ProductCard: Page "Item Card";
                    XValueString: Text;
                begin
                    XValueString := GetJsonTextField(point, 'XValueString');

                    // Open the "Product Card" page and set the record filter to the selected product
                    if XValueString <> '' then begin
                        ProductTable.Reset();
                        ProductTable.SetRange(ProductTable."Name", XValueString);

                        ProductCard.SetTableView(ProductTable);

                        if ProductCard.RunModal() = Action::LookupOK then begin
                            ProductCard.GetRecord(ProductTable);
                        end;
                    end;
                end;

                trigger AddInReady()
                var
                    Buffer: Record "Business Chart Buffer" temporary;
                    Product: Record "CRM Product";
                    Order: Record "Sales Header";
                    i: Integer;
                    j: Integer;

                begin
                    Buffer.Initialize();

                    // Index 0
                    Buffer.AddMeasure('Mon', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 1
                    Buffer.AddMeasure('Tue', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 2
                    Buffer.AddMeasure('Wed', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 3
                    Buffer.AddMeasure('Thu', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 4
                    Buffer.AddMeasure('Fri', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 5
                    Buffer.AddMeasure('Sat', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Index 6
                    Buffer.AddMeasure('Sun', 1, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);

                    // Name the X axis 
                    Buffer.SetXAxis('Product', Buffer."Data Type"::String);

                    // Filter 
                    Product.SetRange("Week sales", 0, 999999); // Set a range to include all records with "Week sales" greater than 0
                    Product.SetCurrentKey("Week sales"); // Set the current key to "Week sales" to sort the records by this field

                    if Product.FindSet(false, false) then
                        repeat
                            if j >= 5 then // how many results do we want 
                                break;
                            Product.CalcFields("Mon sales");
                            if Product."Mon sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(0, i, Product."Mon sales");
                                i += 1;
                            end;

                            Product.CalcFields("Tue sales");
                            if Product."Tue sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(1, i, Product."Tue sales");
                                i += 1;
                            end;

                            Product.CalcFields("Wed sales");
                            if Product."Wed sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(2, i, Product."Wed sales");
                                i += 1;
                            end;

                            Product.CalcFields("Thu sales");
                            if Product."Thu sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(3, i, Product."Thu sales");
                                i += 1;
                            end;

                            Product.CalcFields("Fri sales");
                            if Product."Fri sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(4, i, Product."Fri sales");
                                i += 1;
                            end;

                            Product.CalcFields("Sat sales");
                            if Product."Sat sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(5, i, Product."Sat sales");
                                i += 1;
                            end;

                            Product.CalcFields("Sun sales");
                            if Product."Sun sales" <> 0 then begin
                                Buffer.AddColumn(Product.Name);
                                Buffer.SetValueByIndex(6, i, Product."Sun sales");
                                i += 1;
                            end;

                            j += 1;
                        until Product.Next() = 0;

                    Buffer.Update(CurrPage.Chart);
                end;
            }
        }
    }
    procedure GetJsonTextField(O: JsonObject; Member: Text): Text
    var
        Result: JsonToken;

    begin
        if O.Get(Member, Result) then
            exit(Result.AsValue().AsText());
    end;
}