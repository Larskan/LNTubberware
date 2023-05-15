
codeunit 50205 EmailDefinition
{
    //Task: Send a welcome mail from Dynamics to new the customers.
    //This is the mails themselves
    procedure NewCustomerEmail(customerId: Code[20])
    var
        CustomerTable: Record Customer;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        //Match CustomerTable No. with the customerId parameter
        CustomerTable.SetFilter("No.", customerId);
        CustomerTable.FindFirst();
        Receiver := CustomerTable."E-Mail";

        Subject := 'Welcome to EpicShop';
        Character := 13; //Line shift


        Body := 'Greetings ' + CustomerTable.Name + Format(Character) + Format(Character)
        + 'Welcome to EpicShop' + Format(Character)
        + 'Best Regards' + Format(Character)
        + 'CEO of EpicShop';

        //If Body is not empty
        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::"New Customer");
        end;
    end;

    //Task: Dynamics shall also mail an order confirmation to the customer
    //This is the mails themselves
    procedure NewOrderEmail(orderId: Code[20])
    var
        OrderTable: Record "Sales Header";
        CustomerTable: Record Customer;
        SalesLineTable: Record "Sales Line";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        //Filter on Sales Header record, to match Sales Header No. with the input orderId parameter
        OrderTable.SetFilter("No.", orderId);
        OrderTable.FindFirst();
        //Filter on Sales Line Record to match document number of order within Sales Header record
        SalesLineTable.SetFilter("Document No.", OrderTable."No.");
        //Filter on CustomerTable to match customerID found in Sales Header with the Sales Header
        CustomerTable.SetFilter("No.", OrderTable."Bill-to Customer No.");
        CustomerTable.FindFirst();
        Character := 13; //Line shift
        Receiver := CustomerTable."E-Mail";

        Subject := 'Thanks for shopping!';

        Body := 'Greetings ' + CustomerTable.Name + Format(Character)
        + 'Your Order is in: ' + Format(Character);

        //Searches Sales Line for all records that matches the filter from above
        //Then loop through all products the costumer ordered
        if SalesLineTable.FindSet() then
            repeat
                Body += 'Item: ' + SalesLineTable.Description + ' | Item Amount: ' + Format(SalesLineTable.Quantity)
                    + ' | Price: ' + Format(SalesLineTable."Line Amount") + Format(Character);
            until SalesLineTable.Next() = 0;

        Body += 'Best Regards' + Format(Character)
                + 'CEO of EpicShop';

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::"Create Order");
        end;
    end;
}

enumextension 50225 EmailScenarios extends "Email Scenario"
{
    value(50226; "Create Order")
    {
        Caption = 'Create Order';
    }
    value(50227; "New Customer")
    {
        Caption = 'New Customer';
    }
}