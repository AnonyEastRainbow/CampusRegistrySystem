public with sharing class AccountCustomController {
    public List<Account> getAccounts(){
        List<Account>  accounts = Database.query('select name,phone,BillingStreet,website from Account order by name');
        return accounts;
    }
}