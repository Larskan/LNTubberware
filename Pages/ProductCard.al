page 50200 ProductCard
{
    ApplicationArea = All;
    Caption = 'ProductCard';
    PageType = Card;
    SourceTable = Product;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(ProductID; Rec.ProductID)
                {
                    ToolTip = 'Specifies the value of the ProductID field.';
                }
                field(ProductName; Rec.ProductName)
                {
                    ToolTip = 'Specifies the value of the ProductName field.';
                }
                field(ProductPrice; Rec.ProductPrice)
                {
                    ToolTip = 'Specifies the value of the ProductPrice field.';
                }
            }

        }

    }




}

