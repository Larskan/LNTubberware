table 50301 TubberwareCustomer
{
    Caption = 'Customer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CustomerID; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; CustomerName; Text[200])
        {
            Caption = 'First Name';
            DataClassification = ToBeClassified;
        }
        field(20; CustomerLastName; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = ToBeClassified;
        }
        field(30; CustomerMail; Text[200])
        {
            Caption = 'Mail';
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
