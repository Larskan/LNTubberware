pageextension 50233 TubberCustomerCardExtension extends "Customer List"
{
    layout
    {
        //What is this page for?
        //Extending Customer List to contain a section for the project, aswell as a place for the CustomerMail
        //CustomerMail is necessary for Welcome Mail Task and Order Confirmation

        addlast(Control1)
        {
            field("Customer Mail"; Rec.CustomerMail)
            {
                Caption = 'Customer Mail';
                MultiLine = true;
                Width = 200;
                ToolTip = 'Mail used for details and welcome mails';
            }



        }
    }

    actions
    {

    }
}
