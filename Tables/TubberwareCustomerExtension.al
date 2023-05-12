tableextension 50300 TubberwareCustomerExtension extends Customer
{
    fields
    {
        field(202; CustomerMail; Text[50])
        {
            Caption = 'Mail';
            DataClassification = ToBeClassified;
        }

    }
}
