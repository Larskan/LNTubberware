tableextension 50341 "Product Chart" extends "CRM Product"
{
        field(8; "Current Week"; Integer)
        {
            Caption = 'Current Week, might be a hack';
            DataClassification = ToBeClassified;

        }
        field(9; "Mon sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(1))); // We're using a fixed week as we can't have dates after february
        }
        field(10; "Tue sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(2))); // We're using a fixed week as we can't have dates after february
        }
        field(11; "Wed sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(3))); // We're using a fixed week as we can't have dates after february
        }
        field(12; "Thu sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(4))); // We're using a fixed week as we can't have dates after february
        }
        field(13; "Fri sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(5))); // We're using a fixed week as we can't have dates after february
        }
        field(14; "Sat sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(6))); // We're using a fixed week as we can't have dates after february
        }
        field(15; "Sun sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6), "Order Day" = const(7))); // We're using a fixed week as we can't have dates after february
        }
        field(16; "Week sales"; Integer)
        {
            Caption = 'Times Sold';
            FieldClass = FlowField;
            CalcFormula = count(Orders where("Product" = field(No), "Order Week" = const(6))); // We're using a fixed week as we can't have dates after february
    }
}
