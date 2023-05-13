/*
codeunit 50304 "Email Unit"
{
    procedure SendWelcome(Receiver: Text)
    var
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(Receiver, 'Welcome to Tupper', 'Du er customer hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"NewTupperCustomer")
    end;

    procedure SendOrderConfirmation(Receiver: Text)
    var
        EmailMessage: Codeunit "Email MEssage";
    begin
        EmailMEssage.Create(Receiver, 'Tupper Confirmation', 'Du har bestilt hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"NewTupperOrder")
    end;

    var
        Email: Codeunit Email;
}

enumextension 50305 "Tupper Email Scenarios" extends "Email Scenario"
{
    value(50306; "New Order")
    {
        Caption = 'New Order';
    }
    value(50307; "New Customer")
    {
        Caption = 'New Customer';
    }
}
*/