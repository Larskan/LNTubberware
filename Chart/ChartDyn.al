table 50401 ChartDyn
{
    Caption = 'ProductChart';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CustomerId; Text[100])
        {
            Caption = 'CustomerId';
            DataClassification = ToBeClassified;
        }
        field(10; ChartType; Option)
        {
            Caption = 'Chart Type';
            DataClassification = ToBeClassified;
            OptionMembers = Point,,Bubble,Line,,StepLine,,,,,StackedColumn,StackedColumn100,Area;
            OptionCaption = 'Point,, Bubble, Line,, StepLine,,,,, StackedColumn,StackedColumn100, Area';
        }
        field(20; SoldProduct; Integer)
        {
            Caption = 'SoldProduct';
            DataClassification = ToBeClassified;
        }
        field(30; StartDate; Date)
        {
            Caption = 'Starting Date';
        }
        field(40; EndDate; Date)
        {
            Caption = 'Ending Date';
        }
    }
    keys
    {
        key(PK; CustomerId)
        {
            Clustered = true;
        }
    }
}
