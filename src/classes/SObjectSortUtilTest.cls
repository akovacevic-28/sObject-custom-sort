@IsTest
public class SObjectSortUtilTest {

    private static List<Opportunity> createOpportunities(Integer count) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + (i + 1),
                CloseDate = Date.today().addDays(i + 1),
                StageName = 'Qualification'
            ));
        }
        insert opportunities;
        return opportunities;
    }

    private static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + (i + 1),
                ShippingStreet = 'Test Street ' + (i + 1),
                AnnualRevenue = (i + 1) * 1000
            ));
        }
        insert accounts;
        return accounts;
    }

    @IsTest
    public static void testSortOneStringParam() {
        List<Account> accounts = createAccounts(5);

        SObjectSortUtil sortUtilDESC = new SObjectSortUtil(accounts);
        sortUtilDESC.addSortProperty('Name', 'DESC');
        accounts = sortUtilDESC.sort();

        System.assertEquals('Test Account 5', accounts[0].Name);
        System.assertEquals('Test Account 4', accounts[1].Name);
        System.assertEquals('Test Account 3', accounts[2].Name);
        System.assertEquals('Test Account 2', accounts[3].Name);
        System.assertEquals('Test Account 1', accounts[4].Name);

        SObjectSortUtil sortUtilASC = new SObjectSortUtil(accounts);
        sortUtilASC.addSortProperty('Name');
        accounts = sortUtilASC.sort();

        System.assertEquals('Test Account 1', accounts[0].Name);
        System.assertEquals('Test Account 2', accounts[1].Name);
        System.assertEquals('Test Account 3', accounts[2].Name);
        System.assertEquals('Test Account 4', accounts[3].Name);
        System.assertEquals('Test Account 5', accounts[4].Name);
    }

    @IsTest
    public static void testSortOneNumberParam() {
        List<Account> accounts = createAccounts(5);
     
        SObjectSortUtil sortUtilDESC = new SObjectSortUtil(accounts);
        sortUtilDESC.addSortProperty('AnnualRevenue', 'DESC');
        accounts = sortUtilDESC.sort();

        System.assertEquals(5000, accounts[0].AnnualRevenue);
        System.assertEquals(4000, accounts[1].AnnualRevenue);
        System.assertEquals(3000, accounts[2].AnnualRevenue);
        System.assertEquals(2000, accounts[3].AnnualRevenue);
        System.assertEquals(1000, accounts[4].AnnualRevenue);
     
        SObjectSortUtil sortUtilASC = new SObjectSortUtil(accounts);
        sortUtilASC.addSortProperty('AnnualRevenue');
        accounts = sortUtilASC.sort();

        System.assertEquals(1000, accounts[0].AnnualRevenue);
        System.assertEquals(2000, accounts[1].AnnualRevenue);
        System.assertEquals(3000, accounts[2].AnnualRevenue);
        System.assertEquals(4000, accounts[3].AnnualRevenue);
        System.assertEquals(5000, accounts[4].AnnualRevenue);
    }

    @IsTest
    public static void testSortOneDateParam() {
        List<Opportunity> opportunities = createOpportunities(5);

        SObjectSortUtil sortUtilDESC = new SObjectSortUtil(opportunities);
        sortUtilDESC.addSortProperty('CloseDate', 'DESC');
        opportunities = sortUtilDESC.sort();

        System.assertEquals(Date.today().addDays(5), opportunities[0].CloseDate);
        System.assertEquals(Date.today().addDays(4), opportunities[1].CloseDate);
        System.assertEquals(Date.today().addDays(3), opportunities[2].CloseDate);
        System.assertEquals(Date.today().addDays(2), opportunities[3].CloseDate);
        System.assertEquals(Date.today().addDays(1), opportunities[4].CloseDate);
        
        SObjectSortUtil sortUtilASC = new SObjectSortUtil(opportunities);
        sortUtilASC.addSortProperty('CloseDate', 'ASC');
        opportunities = sortUtilASC.sort();
        
        System.assertEquals(Date.today().addDays(1), opportunities[0].CloseDate);
        System.assertEquals(Date.today().addDays(2), opportunities[1].CloseDate);
        System.assertEquals(Date.today().addDays(3), opportunities[2].CloseDate);
        System.assertEquals(Date.today().addDays(4), opportunities[3].CloseDate);
        System.assertEquals(Date.today().addDays(5), opportunities[4].CloseDate);
    }

    @IsTest
    public static void testSortOneStringParamCustomMap() {
        List<Account> accounts = createAccounts(5);

        accounts[0].ShippingStreet = 'Street A';
        accounts[1].ShippingStreet = 'Street B';
        accounts[2].ShippingStreet = 'Street C';
        accounts[3].ShippingStreet = 'Street D';
        accounts[4].ShippingStreet = 'Street E';

        Map<String,Integer> customMap = new Map<String,Integer>{
            'Street A' => 4,
            'Street B' => 3,
            'Street C' => 2,
            'Street D' => 1,
            'Street E' => 0
        };

        SObjectSortUtil sortUtilASC = new SObjectSortUtil(accounts);
        sortUtilASC.addSortProperty('ShippingStreet', 'ASC', customMap);
        accounts = sortUtilASC.sort();

        System.assertEquals('Street E', accounts[0].ShippingStreet);
        System.assertEquals('Street D', accounts[1].ShippingStreet);
        System.assertEquals('Street C', accounts[2].ShippingStreet);
        System.assertEquals('Street B', accounts[3].ShippingStreet);
        System.assertEquals('Street A', accounts[4].ShippingStreet);

        SObjectSortUtil sortUtilDESC = new SObjectSortUtil(accounts);
        sortUtilDESC.addSortProperty('ShippingStreet', 'DESC', customMap);
        accounts = sortUtilDESC.sort();

        System.assertEquals('Street A', accounts[0].ShippingStreet);
        System.assertEquals('Street B', accounts[1].ShippingStreet);
        System.assertEquals('Street C', accounts[2].ShippingStreet);
        System.assertEquals('Street D', accounts[3].ShippingStreet);
        System.assertEquals('Street E', accounts[4].ShippingStreet);
    }

    @IsTest
    public static void testSortTwoParams() {
        List<Account> accounts = createAccounts(5);

        accounts[0].ShippingStreet = 'Street B'; // 5000
        accounts[1].ShippingStreet = 'Street A'; // 5000
        accounts[2].ShippingStreet = 'Street B'; // 4000
        accounts[3].ShippingStreet = 'Street A'; // 9000
        accounts[4].ShippingStreet = 'Street B'; // 9000

        accounts[0].AnnualRevenue = 5000;
        accounts[1].AnnualRevenue = 5000;
        accounts[2].AnnualRevenue = 4000;
        accounts[3].AnnualRevenue = 9000;
        accounts[4].AnnualRevenue = 9000;

        SObjectSortUtil sortUtil = new SObjectSortUtil(accounts);
        sortUtil.addSortProperty('AnnualRevenue', 'DESC');
        sortUtil.addSortProperty('ShippingStreet', 'ASC');
        accounts = sortUtil.sort();

        System.assertEquals(9000, accounts[0].AnnualRevenue);
        System.assertEquals(9000, accounts[1].AnnualRevenue);
        System.assertEquals(5000, accounts[2].AnnualRevenue);
        System.assertEquals(5000, accounts[3].AnnualRevenue);
        System.assertEquals(4000, accounts[4].AnnualRevenue);

        System.assertEquals('Street A', accounts[0].ShippingStreet);
        System.assertEquals('Street B', accounts[1].ShippingStreet);
        System.assertEquals('Street A', accounts[2].ShippingStreet);
        System.assertEquals('Street B', accounts[3].ShippingStreet);
        System.assertEquals('Street B', accounts[4].ShippingStreet);
    }
}