page 50201 TubberwareCustomerCard
{
    ApplicationArea = All;
    Caption = 'TubberwareCustomerCard';
    PageType = List;
    SourceTable = TubberwareCustomer;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(CustomerID; Rec.CustomerID) { ToolTip = 'ID'; }
                field(CustomerName; Rec.CustomerName)
                {
                    ToolTip = 'First Name';
                }
                field(CustomerLastName; Rec.CustomerLastName)
                {
                    ToolTip = 'Last Name';
                }
                field(CustomerMail; Rec.CustomerMail)
                {
                    ToolTip = 'Mail';
                }
            }
        }
    }
}
