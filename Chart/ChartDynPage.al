page 50402 ChartDynPage
{
    ApplicationArea = All;
    Caption = 'Chart Dyn Page';
    PageType = Card;
    SourceTable = ChartDyn;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Chart type"; Rec.ChartType)
                {
                    ApplicationArea = All;

                }
                field(StartDate; Rec.StartDate)
                {
                    ApplicationArea = All;
                }
                field(EndDate; Rec.EndDate)
                {
                    ApplicationArea = All;
                }
            }

            group(ChartGroup)
            {
                usercontrol(Chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                {
                    ApplicationArea = All;
                    //DataPointClicked = What happens when user clicks on data point
                    //TASK: If the user clicks on the chart item, then drill down and show the product on the item card.
                    trigger DataPointClicked(point: JsonObject)
                    var
                        ItemChart: Record ChartDyn;
                        Stuff: Record Item;
                        Token: JsonToken;
                    begin
                        //if something with XValueString then begin ?? 
                        //Get needs a key and a token. XValueString is our ID's I assume
                        if point.Get('XValueString', Token) then begin
                            //Get selected chart items X Value aka hopefully the customer ID
                            ItemChart.Get('CustomerId', point.Get('XValueString', Token));
                            //Get product that matches , hopefully
                            Stuff.SetFilter(Stuff."No.", ItemChart.CustomerId);
                            if Stuff.FindFirst() then begin
                                //open item card page that matches it
                                //Drawing a blank here
                            end;
                        end;
                    end;

                    trigger AddInReady()
                    var
                        ChartData: Record ChartDyn;
                        Json: JsonObject;
                        ChartType: Option;

                    begin
                        //Unsure if this is correct or not
                        ChartType := Rec.ChartType;
                        ChartData.StartDate := Rec.StartDate;
                        ChartData.EndDate := Rec.EndDate;

                    end;

                }

            }
        }


    }
}
