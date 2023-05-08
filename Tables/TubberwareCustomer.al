table 50301 TubberwareCustomer
{
    Caption = 'Customer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CustomerID; Integer)
        {
            Caption = 'CustomerID';
            DataClassification = ToBeClassified;
        }
        field(10; CustomerName; Text[200])
        {
            Caption = 'CustomerName';
            DataClassification = ToBeClassified;
        }
        field(20; CustomerMail; Text[200])
        {
            Caption = 'CustomerMail';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; CustomerID)
        {
            Clustered = true;
        }
    }
}
