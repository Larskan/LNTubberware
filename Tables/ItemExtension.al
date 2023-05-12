tableextension 50158 ItemExtension extends Item
{
    fields
    {
        field(50159; ItemDescription; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
        }
        field(50160; WooCommerceID; Text[100])
        {
            Caption = 'WooCommerce ID';
            DataClassification = ToBeClassified;
        }
    }
}