/*
pageextension 50119 plsWork extends ProductCard
{
    actions
    {
        addlast(processing)
        {
            action(GetWooProducts)
            {
                ApplicationArea = All;
                Caption = 'Get WooCommerce Products';

                trigger OnAction()
                var
                    Woo: Codeunit WooCommerceConnector;
                begin
                    Woo.GetProducts();
                end;
            }
        }
    }

    var
        Woo: Codeunit WooCommerceConnector;
}
*/
