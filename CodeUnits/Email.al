
//Code from earlier project, has not been tested
codeunit 50205 EmailDefinition
{
    //Task: Send a welcome mail from Dynamics to new the customers.
    procedure NewCustomerEmail(customerID: Code[20])
    var
        CustomerTable: Record Customer;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        Receiver: Text;
        Character: Char;
    begin
        CustomerTable.SetFilter("No.", customerID);
        CustomerTable.FindFirst();
        //Receiver := 'heinotestmail@gmail.com'; //- For testing
        Receiver := CustomerTable."E-Mail";
        Subject := 'Welcome to EpicShop';
        Character := 13; //Line shift

        Body := 'Greetings' + CustomerTable.Name + Format(Character) + Format(Character)
        + 'Welcome to EpicShop' + Format(Character)
        + 'Hope you enjoy our shop and have a good experience' + Format(Character)
        + 'Best Regards' + Format(Character)
        + 'CEO of EpicShop' + Format(Character);

        //If Body is not empty
        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::"New Customer");
        end;
    end;

    //Task: Dynamics shall also mail an order confirmation to the customer
<<<<<<< HEAD
    //procedure NewOrderEmail(OrderID: Code[20])
=======
    procedure NewOrderEmail(orderID: Code[20])
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
        OrderTable.SetFilter("No.", orderID);
        OrderTable.FindFirst();
        SalesLineTable.SetFilter("Document No.", OrderTable."No.");
        CustomerTable.SetFilter("No.", OrderTable."Bill-to Customer No.");
        CustomerTable.FindFirst();
        Receiver := 'heinotestmail@gmail.com'; //- for testing
        //Receiver := CustomerTable."E-Mail";
        Subject := 'Thanks for shopping!';
        Character := 13; //Line shift, Format(Character)
>>>>>>> 2a0501c48f269787b0b1c26039eb49f88ed7cd10

        Body := 'Greetings.' + CustomerTable.Name + Format(Character) + Format(Character)
        + 'Thank you for shopping in EpicShop' + Format(Character)
        + 'Your Order: ' + Format(Character);

        if SalesLineTable.FindSet() then
            repeat
                Body += 'Item: ' + SalesLineTable.Description
                + ' | Amount: ' + Format(SalesLineTable.Quantity)
                + ' | Price: ' + Format(SalesLineTable."Line Amount") + Format(Character);
            until SalesLineTable.Next() = 0;

        Body := 'Please come again!' + Format(Character)
        + 'Best Regards' + Format(Character)
        + 'CEO of EpicShop' + Format(Character);

        if not (Body = '') then begin
            EmailMessage.Create(Receiver, Subject, Body);
            Email.Send(EmailMessage, "Email Scenario"::"Order Creation");
        end;
    end;
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