
codeunit 50304 "Email Unit"
{
    procedure SendWelcome(customer: code[20])
    var
        CustomerTable: Record Customer;
        EmailMessage: Codeunit "Email Message";
    begin
        CustomerTable.SetFilter("No.", customer);
        CustomerTable.FindFirst();
        customer := CustomerTable."E-Mail";

        EmailMessage.Create(customer, 'Welcome to Tupper', 'Du er customer hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"New Customer")
    end;

    procedure SendOrderConfirmation(customer: code[20])
    var
        CustomerTable: Record Customer;
        EmailMessage: Codeunit "Email Message";
    begin
        CustomerTable.SetFilter("No.", customer);
        CustomerTable.FindFirst();
        customer := CustomerTable."E-Mail";

        EmailMessage.Create(customer, 'Tupper Confirmation', 'Du har bestilt hos LN|Tupper!');
        Email.Send(EmailMessage, "Email Scenario"::"Order Creation")
    end;

    var
        Email: Codeunit Email;
}