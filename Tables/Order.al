table 50205 "Order"
{
    Caption = 'Order';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ORDER NUMBER"; Integer)
        {
            Caption = 'ORDER NUMBER';
            DataClassification = ToBeClassified;
        }
        field(10; "DATE"; Text[100])
        {
            Caption = 'DATE';
            DataClassification = ToBeClassified;
        }
        field(20; EMAIL; Text[200])
        {
            Caption = 'EMAIL';
            DataClassification = ToBeClassified;
        }
        field(30; TOTAL; Text[100])
        {
            Caption = 'TOTAL';
            DataClassification = ToBeClassified;
        }
        field(40; "PAYMENT METHOD"; Text[100])
        {
            Caption = 'PAYMENT METHOD';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "ORDER NUMBER")
        {
            Clustered = true;
        }
    }
}
