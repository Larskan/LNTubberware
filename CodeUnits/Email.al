codeunit 50205 EmailController
{
    procedure NewCustomerEmail(CusID: Code[20])
    var
        CustomerTable: Record TubberwareCustomer;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        CustomerTable.SetFilter(CustomerID, CusID);
        Receiver := 'ninusjunk@outlook.com';
        Subject := 'Welcome to EpicShop';
        Body := '';
        Character := 13;

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::Default);
        end;
    end;

    procedure NewOrderEmail(orderID: Code[20])
    var
        OrderTable: Record "Sales Header";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        OrderTable.SetFilter("No.", orderID);
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