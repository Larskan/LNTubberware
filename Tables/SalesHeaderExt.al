tableextension 50321 SalesHeaderExtension extends "Sales Header"
{
    trigger OnInsert()
    var

        Emailunit: Codeunit 50304;
    begin
        //Note to Nico: You cannot have 2 seperate extensions of the same area like Sales Header
        //So I put them same place for now, but we don't need the SendWelcome, I got that to work
        //Still struggling with the Order Confirmation
        Emailunit.SendOrderConfirmation(Rec."Sell-to Customer No.");
        Emailunit.SendWelcome(Rec."Sell-to Customer No.");
    end;
}