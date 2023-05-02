table 50100 Product
{
    Caption = 'Product';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ProductID; Integer)
        {
            Caption = 'ProductID';
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(10; ProductName; Text[100])
        {
            Caption = 'ProductName';
            DataClassification = ToBeClassified;
        }
        field(20; ProductPrice; Text[100])
        {
            Caption = 'ProductPrice';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; ProductID)
        {
            Clustered = true;
        }
    }
}
