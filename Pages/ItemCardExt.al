pageextension 50109 ItemCardExt extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            //field(ItemDescription; Rec.ItemDescription)
            // {
            //  Caption = 'Item Description';
            //   MultiLine = true;
            //  Width = 200;
            // }
        }
    }

    actions
    {
        addlast(Functions)
        {
            action(WooCommerce)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                Caption = 'WooCommerce Upload';
                Image = UpdateShipment;
                ToolTip = 'Uploads current item to WooCommerce';

                trigger OnAction()
                var
                    Woo: Codeunit WebConnectOut;
                begin
                    Woo.NewTubber(Rec."No.");
                end;
            }
        }
    }
}
