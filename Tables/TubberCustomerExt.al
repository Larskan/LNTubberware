tableextension 50300 TubberCustomer extends Customer
{
    fields
    {
        field(200; CustomerName; Text[50])
        {
            Caption = 'First Name';
        }
        field(201; CustomerLastName; Text[50])
        {
            Caption = 'Last Name';
        }
        field(202; CustomerMail; Text[50])
        {
            Caption = 'Mail';
        }

    }
}
