public with sharing class AccountHelper {
    public static void checkCnpj(List<Account> accountList) {
        for (Account account : accountList) {
            if (String.isBlank(account.CnpjExternalId__c)) {
                account.addError(System.label.CnpjRequired);
            } else {
                fillFormattedCnpj(account);
            }        
        }
    }

    public static void checkCnpj(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        List<Account> accountListUpdated = new List<Account>();
        for (Account newAccount : newMap.values()) {
            Account oldAccount = oldMap.get(newAccount.Id);
            
            if (newAccount.CnpjExternalId__c != oldAccount.CnpjExternalId__c) {
                accountListUpdated.add(newAccount);
            }
        }
        checkCnpj(accountListUpdated);
    }
    
    public static void fillFormattedCnpj(Account account) {
        String cnpj = formatCnpj(account.CnpjExternalId__c);
        if (!isCnpjValid(cnpj)) account.addError(System.label.CnpjError);
        checkDuplicated(account);
    }

    public static String formatCnpj(String cnpj) {
        return cnpj.replaceAll('(\\d{2})(\\d{3})(\\d{3})(\\d{4})(\\d{2})', '$1.$2.$3/$4-$5');
    }

    public static void checkDuplicated(Account account) {     
        String cnpj = formatCnpj(account.CnpjExternalId__c);
        try {
            Account oldAccount = [ SELECT Name, CnpjExternalId__c FROM Account WHERE CnpjExternalId__c = :cnpj LIMIT 1 ];
            if (oldAccount != null) account.addError(System.label.DuplicatedCnpjError + ' ' + oldAccount.Name);
        }
        catch (Exception e) {
            account.CnpjExternalId__c = cnpj;    
        }
    }

    public static Boolean isCnpjValid(String accountCnpj) {
        String cnpj = accountCnpj.replaceAll('[^0-9]', '');

        if (cnpj.length() != 14 || !String.valueOf(cnpj).isNumeric()) return false;

        Integer sm, i, r, num, peso, dig13, dig14;
        List<String> cnpjString = cnpj.split('');
        sm = 0;
        peso = 2;
        for (i=11; i>=0; i--) {
            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;
            if (peso == 10)
                peso = 2;
        }

        r = math.mod(sm, 11);
        if ((r == 0) || (r == 1)) dig13 = 0;
        else dig13 = Integer.valueOf(11-r);
        
        sm = 0;
        peso = 2;
        for (i=12; i>=0; i--) {
            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;
            if (peso == 10) peso = 2;
        }

        r = math.mod(sm, 11);
        if ((r == 0) || (r == 1))
            dig14 = 0;
        else dig14 = Integer.valueOf(11-r);

        if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13])) return true;
        else return false ;
    }
}