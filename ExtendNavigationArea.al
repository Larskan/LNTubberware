pageextension 50230 ExtendNavigationArea extends "Order Processor Role Center"
{
    //Easy access on the Website
    actions
    {
        addlast(sections)
        {
            group("Tubberware")
            {
                action("Mails")
                {
                    //RunObject = page ProjectDocument;
                    //ApplicationArea = All;
                }
                action("Products")
                {
                    RunObject = page ProductCard;
                    ApplicationArea = All;
                }
                action("TubberCustomer")
                {
                    RunObject = page TubberwareCustomerCard;
                    ApplicationArea = All;
                }
            }
        }
    }
}