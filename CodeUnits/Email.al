
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
        CustomerTable.FindFirst();
        //Receiver := 'ninusjunk@outlook.com'; - For testing
        Receiver := CustomerTable."E-Mail";
        Subject := 'Welcome to EpicShop';
        Character := 13; //Line shift

        Body := 'Greeting' + CustomerTable.Name + Format(Character) + Format(Character)
        + 'Welcome to EpicShop' + Format(Character)
        + 'Hope you enjoy our shop and have a good experience' + Format(Character)
        + 'Best Regards' + Format(Character)
        + 'CEO of EpicShop' + Format(Character);

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::"New Customer");
        end;
    end;

    //Task: Dynamics shall also mail an order confirmation to the customer
    procedure NewOrderEmail(OrderID: Code[20])

}

enumextension 50225 EmailScenarios extends "Email Scenario"
{
    value(50226; "Order Creation")
    {
        Caption = 'Order Creation';
    }
    value(50227; "New Customer")
    {
        Caption = 'New Customer';
    }
}