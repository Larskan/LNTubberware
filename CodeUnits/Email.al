
//Code from earlier project, has not been tested
codeunit 50205 EmailController
{
    //Task: Send a welcome mail from Dynamics to new the customers.
    procedure NewCustomerEmail(CustomerID: Code[20])
    var
        CustomerTable: Record Customer;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        CustomerTable.SetFilter("No.", CustomerID);
        Receiver := 'ninusjunk@outlook.com';
        Subject := 'Welcome to EpicShop';
        Body := '';
        Character := 13;

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::Default);
        end;
    end;

    //Task: Dynamics shall also mail an order confirmation to the customer
    procedure NewOrderEmail(OrderID: Code[20])
    var
        OrderTable: Record "Sales Header";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        OrderTable.SetFilter("No.", OrderID);
        Receiver := 'ninusjunk@outlook.com';
        Subject := 'Welcome to EpicShop';
        Body := '';
        Character := 13;

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::Default);
        end;
    end;
}