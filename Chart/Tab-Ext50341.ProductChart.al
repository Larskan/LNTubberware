tableextension 50341 "Product Chart" extends "CRM Product"
{
    fields
    {

        field(201; "Current Week"; Integer)
        {
            Caption = 'Current Week';
            DataClassification = ToBeClassified;

        }
        field(202; "Mon sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(1))); // We're using a fixed week as we can't have dates after february
        }
        field(203; "Tue sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(2))); // We're using a fixed week as we can't have dates after february
        }
        field(204; "Wed sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(3))); // We're using a fixed week as we can't have dates after february
        }
        field(205; "Thu sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(4))); // We're using a fixed week as we can't have dates after february
        }
        field(206; "Fri sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(5))); // We're using a fixed week as we can't have dates after february
        }
        field(207; "Sat sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(6))); // We're using a fixed week as we can't have dates after february
        }
        field(208; "Sun sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(7))); // We're using a fixed week as we can't have dates after february
        }
        field(209; "Week sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6))); // We're using a fixed week as we can't have dates after february
        }
    }
}