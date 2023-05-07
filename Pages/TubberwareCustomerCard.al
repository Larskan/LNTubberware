page 50101 TubberwareCustomerCard
{
    ApplicationArea = All;
    Caption = 'TubberwareCustomerCard';
    PageType = Card;
    SourceTable = TubberwareCustomer;
    
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                
                field(CustomerID; Rec.CustomerID)
                {
                    ToolTip = 'Specifies the value of the CustomerID field.';
                }
                field(CustomerName; Rec.CustomerName)
                {
                    ToolTip = 'Specifies the value of the CustomerName field.';
                }
                field(CustomerMail; Rec.CustomerMail)
                {
                    ToolTip = 'Specifies the value of the CustomerMail field.';
                }
            }
        }
    }
}
