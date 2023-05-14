tableextension 50321 "Sales Order Extension" extends "Sales Header"
{
    trigger OnInsert()
    var

        Emailunit: Codeunit 50304;
    begin
        Emailunit.SendOrderConfirmation(Rec."Sell-to Customer No.");
    end;
}
tableextension 50322 "Sales Order Extension" extends "Sales Header"
{
    trigger OnInsert()
    var
        Emailunit: Codeunit 50304;
    begin
        Emailunit.SendWelcome(Rec."Sell-to Customer No.");
    end;
}
