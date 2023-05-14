
codeunit 50304 "Email Unit"
{
    procedure SendWelcome(Receiver: Text)
    var
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(Receiver, 'Welcome to Tupper', 'Du er customer hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"New Customer")
    end;

    procedure SendOrderConfirmation(Receiver: Text)
    var
        EmailMessage: Codeunit "Email MEssage";
    begin
        EmailMEssage.Create(Receiver, 'Tupper Confirmation', 'Du har bestilt hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"Create Order")
    end;

    var
        Email: Codeunit Email;
}

