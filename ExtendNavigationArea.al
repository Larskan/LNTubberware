pageextension 50230 ExtendNavigationArea extends "Order Processor Role Center"
{
    //Easy access on the Website
    actions
    {
        addlast(sections)
        {
            group("Tupperware")
            {
                action("Item Card")
                {
                    RunObject = page "Item List";
                    ApplicationArea = All;
                }
                action("Customer Card")
                {
                    RunObject = page "Customer Card";
                    ApplicationArea = All;
                }
                action("Customer List")
                {
                    RunObject = page "Customer List";
                    ApplicationArea = All;
                }
                action("Web Services")
                {
                    RunObject = page "Web Services";
                    ApplicationArea = All;
                }
                action("Sales Order List")
                {
                    RunObject = page "Sales Order List";
                    ApplicationArea = All;
                }
                action("Item Journal")
                {
                    RunObject = page "Item Journal";
                    ApplicationArea = All;
                }
            }
        }
    }
}