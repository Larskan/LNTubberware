pageextension 50109 ItemCardExtension extends "Item Card"
{
    layout
    {

        addlast(Item)
        {
            field(ItemDescription; Rec.ItemDescription)
            {
                Caption = 'Item Description';
                MultiLine = true;
                Width = 200;
            }
        }
    }

    //To find these:
    //Go to Items in BC(Check Navigation, the one called Item Card) -> Click on Item
    actions
    {
        addlast(Functions)
        {
            //Task: When a product is added to Dynamics it must be possible to export it to WooCommerce
            action(WooCommerce)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Caption = 'Upload to WooCommerce';
                Image = UpdateShipment;
                ToolTip = 'Uploads current item to WooCommerce';

                trigger OnAction()
                var
                    Woo: Codeunit ToWoocommerce;
                begin
                    Woo.ProcessCreateItem(Rec."No.");
                end;
            }

            //Task: If the stock is changed, then it must be reflected in WooCommerce.
            action(WooCommerceUpdate)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Caption = 'Update Item Stock to WooCommerce';
                Image = UpdateShipment;
                ToolTip = 'Uploads current item stock to WooCommerce';

                trigger OnAction()
                var
                    Woo: Codeunit ToWoocommerce;
                begin
                    Woo.ProcessUpdateItemStock(rec."No.");
                end;
            }
        }
    }
}
