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
