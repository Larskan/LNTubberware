codeunit 50215 TubberWooCommerceService
{
    procedure CreateCustomer(customerData: Text)
    var
        jsonConverter: Codeunit 50200;
        customer: Record TubberwareCustomer;
        jsonObj: JsonObject;
    begin
        jsonObj.ReadFrom(customerData);

        //Extract data from JSON
        customer.CustomerName := jsonConverter.getFileIdTextAsText(jsonObj, 'First name');
        customer.CustomerLastName := jsonConverter.getFileIdTextAsText(jsonObj, 'Last name');
        customer.CustomerMail := jsonConverter.getFileIdTextAsText(jsonObj, 'Email adress');

        //create new customer record
        customer.Insert();

        //success reponse to WooCommerce
        Message('Customer created successfully');
    end;

}
