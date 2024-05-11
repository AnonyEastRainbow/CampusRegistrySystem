//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 //  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 //  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 //  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 //  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 //  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 //  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 //  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


/**
 * @author benahm
 * @date 2017
 * @group Test
 * @description TestDataFactory_Test Class
 */
@isTest
public class RS_TestDataFactory_Tst {


	/************************* RS_TestDataFactory_Cmn tests *************************/
	/**
	 * @description create an Account sObject instance (insert flag = false)
	 */
	@isTest
	static void createSObjectTest1(){
		Test.startTest();
		SObject sObj = RS_TestDataFactory_Cmn.createSObject('Account',false);
		Test.stopTest();
		System.assertNotEquals(null,sObj);
	}
	/**
	 * @description create an Account sObject instance (insert flag = false) and passing an empty map
	 */
	@isTest
	static void createSObjectTest2(){
		Test.startTest();
		SObject sObj = RS_TestDataFactory_Cmn.createSObject('Account',new Map<String,Object>(),false);
		Test.stopTest();
		System.assertNotEquals(null,sObj);
	}
	/**
	 * @description create a Case sObject instance (insert flag = false) and passing an complex map of values
	 */
	@isTest
	static void createSObjectTest3(){
		Test.startTest();
		Case cse = (Case)RS_TestDataFactory_Cmn.createSObject('Case', new Map<String,Object> {
			'Contact.FirstName' => 'test',
			'Contact.Account.Name' => 'test',
			'Contact.Account.Parent.Name' => 'test'
		},false);
		Test.stopTest();
		System.assertEquals('test',cse.Contact.FirstName);
		System.assertEquals('test',cse.Contact.Account.Name);
		System.assertEquals('test',cse.Contact.Account.Parent.Name);
	}
	/**
	 * @description create a Case sObject instance (insert flag = true) and passing an complex map of values and DEFAULT_VALUE
	 */
	@isTest
	static void createSObjectTest4(){
		BusinessHours caseBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = TRUE LIMIT 1];
        Test.startTest();
        SObject sObj = RS_TestDataFactory_Cmn.createSObject('Case', new Map<String,Object>{
            'Id' => null,
				'id' => null,
				'BusinessHoursId' => caseBusinessHours.Id,
				'aCCount.Description' => 'test',
				'ConTact.FirstName'=> 'test',
				'Description' => 'test',
				'asset.accounT.Name' => 'test',
				'asset.contact.account.Description' => 'test',
				'asset.Parent.contact.account.Description' => RS_TestDataFactory_Cmn.DEFAULT_VALUE
        }, true);
        Test.stopTest();
		Case cse = [select Asset.Parent.Contact.Account.Name, Asset.Parent.Contact.Account.Description from Case limit 1];
		System.assertEquals('test0',cse.Asset.Parent.Contact.Account.Name);
		System.assertEquals('test0',cse.Asset.Parent.Contact.Account.Description);
	}
	/**
	 * @description create a Case sObject instance (insert flag = false) and passing an nested map of values
	 */
	@isTest
	static void createSObjectTest5(){
		Test.startTest();
		Case cse = (Case)RS_TestDataFactory_Cmn.createSObject('Case', new Map<String,Object> {
			'Contact' => new Map<String,Object> {
			        'Firstname' => 'test',
			        'Account' => new Map<String,Object> {
			                'Name' => 'test',
			                'Description' => 'test'
				}
			}
		},false);
		Test.stopTest();
		System.assertEquals('test',cse.Contact.FirstName);
		System.assertEquals('test',cse.Contact.Account.Name);
		System.assertEquals('test',cse.Contact.Account.Description);
	}
	/**
	 * @description create an Account sObject instance (insert flag = true)
	 *              create a Case (insert flag = false) and use the created account in a nested map of values
	 */
	@isTest
	static void createSObjectTest6(){
		Test.startTest();
		Account acc = (Account)RS_TestDataFactory_Cmn.createSObject('Account',new Map<String,Object> {
			'Name' => 'test',
			'Description' => 'test'
		},true);
		Case cse = (Case)RS_TestDataFactory_Cmn.createSObject('Case', new Map<String,Object> {
			'Contact' => new Map<String,Object> {
			        'Firstname' => 'test',
			        'Account' => acc
			}
		},false);
		Test.stopTest();
		System.assertEquals('test',cse.Contact.FirstName);
		System.assertEquals(acc.Id,cse.Contact.AccountId);
	}
	/**
	 * @description create an Account sObject instance (insert flag = true) pass an Id in the map of values
	 */
	@isTest
	static void createSObjectTest7(){
		Test.startTest();
		SObject sObj = RS_TestDataFactory_Cmn.createSObject('Account', new Map<String,Object> {
			'Name'=> 'test',
			'OwnerId'=> UserInfo.getUserId()
		});
		Test.stopTest();
		Account acc = [select OwnerId from Account limit 1];
		System.assertEquals(UserInfo.getUserId(),acc.OwnerId);
	}
	/**
	 * @description create an Account sObject instance (insert flag = false) that trigger the creation of a user, by pass an username & profileId in the map of values
	 */
	@isTest
	static void createSObjectTest8(){
        Test.startTest();
		Account acc = (Account)RS_TestDataFactory_Cmn.createSObject('Account', new Map<String,Object>{
			'Owner.Username' => 'test123456789@mycompanydomain.developer',
			'Owner.ProfileId' => UserInfo.getProfileId()
			},false);
        Test.stopTest();
		System.assertNotEquals(null,acc);
		System.assertEquals(UserInfo.getProfileId(),((User)acc.Owner).ProfileId);
	}
	/**
	 * @description create an sobject that does not exists
	 */
	@isTest
	static void createSObjectTest9(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('TEST');
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create an object that cannot be created via Apex
	 */
	@isTest
	static void createSObjectTest10(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Profile');
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create an asset object without specifying an AccountId of ContactId
	 */
	@isTest
	static void createSObjectTest11(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Asset');
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create an Account sobject instance in a Person Account enabled org the record type should be set automatically
	 */
	@isTest
	static void createSObjectTest12(){
		if(RS_TestDataFactory_Cmn.isPersonAccountEnabled) {
			// Positive test
			try{
				Test.startTest();
				SObject sObj = RS_TestDataFactory_Cmn.createSObject('Account');
				Test.stopTest();
				System.assert (true);
			}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
				System.assert (false);
			}

		}
	}
	/**
	 * @description create an Account sobject instance in a Person Account enabled org by passing a bad record type id
	 */
	@isTest
	static void createSObjectTest13(){
		if(RS_TestDataFactory_Cmn.isPersonAccountEnabled) {
			// Negative test
			try{
				Test.startTest();
				SObject sObj = RS_TestDataFactory_Cmn.createSObject('Account',new Map<String,Object> {
					'RecordTypeId' => 'BadId'
				});
				Test.stopTest();
				System.assert (false);
			}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
				System.assert (true);
			}
		}
	}
	/**
	 * @description create a Contact sobject instance with a bad field name in the map of values
	 */
	@isTest
	static void createSObjectTest14(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Contact',new Map<String,Object> {
				'Test' => 'test'
			});
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create a Contact sobject instance with a bad field name in the map of values
	 */
	@isTest
	static void createSObjectTest15(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Contact',new Map<String,Object> {
				'Account.Test' => 'test'
			});
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create a Contact sobject instance with a bad value for an id in the map of values
	 */
	@isTest
	static void createSObjectTest16(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Contact',new Map<String,Object> {
				'Account.Test.Parent.Id' => 'test'
			});
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create a Contact sobject instance with a bad type of value in the map of values
	 */
	@isTest
	static void createSObjectTest17(){
		try{
			Test.startTest();
			SObject sObj = RS_TestDataFactory_Cmn.createSObject('Contact',new Map<String,Object> {
				'Description' => Date.today()
			});
			Test.stopTest();
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	/**
	 * @description create a list of 5 Contact sobject instances (insert flag = false)
	 */
	@isTest
	static void createSObjectListTest1(){
		Test.startTest();
		List<SObject> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Contact',5,false);
		Test.stopTest();
		System.assertNotEquals(null,sObjList);
		System.assertEquals(5,sObjList.size());
	}
	/**
	 * @description create a list of 200 Contact sobject instances (insert flag = true)
	 */
	@isTest
	static void createSObjectListTest2(){
		Test.startTest();
		List<SObject> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Contact',200);
		Test.stopTest();
		System.assertNotEquals(null,sObjList);
		System.assertEquals(200,sObjList.size());
	}
	/**
	 * @description create a list of 200 Contact sobject instances (insert flag = false) with an empty map of values
	 */
	@isTest
	static void createSObjectListTest3(){
		Test.startTest();
		List<SObject> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Contact',new Map<String,Object>(),5,false);
		Test.stopTest();
		System.assertNotEquals(null,sObjList);
		System.assertEquals(5,sObjList.size());
	}
	/**
	 * @description create a list of 5 Contact sobject instances (insert flag = true) with an empty map of values
	 */
	@isTest
	static void createSObjectListTest4(){
		Test.startTest();
		List<Contact> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Contact',new Map<String,Object>(),5);
		Test.stopTest();
		System.assertNotEquals(null,sObjList);
		System.assertEquals(5,sObjList.size());
		System.assertEquals('test0',sObjList.get(0).Lastname);
		System.assertEquals('test1',sObjList.get(1).Lastname);
		System.assertEquals('test2',sObjList.get(2).Lastname);
		System.assertEquals('test3',sObjList.get(3).Lastname);
		System.assertEquals('test4',sObjList.get(4).Lastname);
	}
	/**
	 * @description create a list of 10 Contact sobject instances (insert flag = true) with a list for lastname in the map of values
	 */
	@isTest
	static void createSObjectListTest5(){
		Test.startTest();
		List<Contact> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Contact',new Map<String,Object> {
			'Lastname' => new List<String> {'test4','test3','test2','test1','test0'}
		},10,false);
		Test.stopTest();
		System.assertNotEquals(null,sObjList);
		System.assertEquals(10,sObjList.size());
		System.assertEquals('test4',sObjList.get(0).Lastname);
		System.assertEquals('test3',sObjList.get(1).Lastname);
		System.assertEquals('test2',sObjList.get(2).Lastname);
		System.assertEquals('test1',sObjList.get(3).Lastname);
		System.assertEquals('test0',sObjList.get(4).Lastname);
		System.assertEquals('test4',sObjList.get(5).Lastname);
		System.assertEquals('test3',sObjList.get(6).Lastname);
		System.assertEquals('test2',sObjList.get(7).Lastname);
		System.assertEquals('test1',sObjList.get(8).Lastname);
		System.assertEquals('test0',sObjList.get(9).Lastname);
	}
	/**
	 * @description create a list of 2 Account sobject instances (insert flag = true)
	 *              create a list of 2 Contact sobject instances with the created account in the map of values
	 */
	@isTest
	static void createSObjectListTest6(){
		Test.startTest();
		List<Account> accList = RS_TestDataFactory_Cmn.createSObjectList('Account',new Map<String,Object> {
			'Name' => 'test',
			'Description' => 'test'
		},2);
		List<Case> cseList = RS_TestDataFactory_Cmn.createSObjectList('Case', new Map<String,Object> {
			'Contact' => new Map<String,Object> {
			        'Firstname' => 'test',
			        'Account' => accList
			}
		},2,false);
		Test.stopTest();
		System.assertEquals('test',cseList.get(0).Contact.FirstName);
		System.assertEquals('test',cseList.get(1).Contact.FirstName);
		System.assertEquals(accList.get(0).Id,cseList.get(0).Contact.AccountId);
		System.assertEquals(accList.get(1).Id,cseList.get(1).Contact.AccountId);
	}
	/**
	 * @description create a list of 5 Account sobject instances (insert flag = true) that trigger the create of a list of users for the ower field
	 */
	@isTest
	static void createSObjectListTest7(){
		Test.startTest();
		List<SObject> sObjList = RS_TestDataFactory_Cmn.createSObjectList('Account', new Map<String,Object> {
			'Owner.Username' => 'test123456789@mycompanydomain.developer{!index}',
			'Owner.CommunityNickname' => 'testd{!index}',
			'Owner.ProfileId' => UserInfo.getProfileId()
		},5);
		Test.stopTest();
		List<User> uList = [select Id,ProfileId from User where Username LIKE 'test123456789@mycompanydomain.developer%'];
		System.assertNotEquals(null,uList);
		System.assertEquals(5,uList.size());
		System.assertEquals(UserInfo.getProfileId(),uList.get(0).ProfileId);
	}
	/**
	 * @description setting the default value provider
	 */
	@isTest
	static void setDefaultValueProviderTest(){
		System.assertNotEquals(null,RS_TestDataFactory_Cmn.defaultValueProvider);
		RS_TestDataFactory_Cmn.defaultValueProvider = null;
		System.assertNotEquals(null,RS_TestDataFactory_Cmn.defaultValueProvider);
		RS_TestDataFactory_Cmn.defaultValueProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		System.assertNotEquals(null,RS_TestDataFactory_Cmn.defaultValueProvider);
	}


	/************************* SObjectManager tests *************************/
	/**
	 * @description getting the main sobject list from the sObject Manager
	 */
	@isTest
	static void getMainSObjectListTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		System.assertNotEquals(null,sObjManager.getMainSObjectList());
		System.assertEquals(0,sObjManager.getMainSObjectList().size());
		sObjManager.mainSObjectList.add(new Contact());
		System.assertEquals(1,sObjManager.getMainSObjectList().size());
	}
	/**
	 * @description setting sObject on the sObject Manager
	 */
	@isTest
	static void setSObjectTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		try{
			sObjManager.setSObject(1,new Contact(FirstName='test1'));
			System.assert (false);
		}catch(ListException e) {
			System.assert (true);
		}
		sObjManager.setSObject(0,new Contact(FirstName='test1'));
		System.assertEquals(1,sObjManager.mainSObjectList.size());
		System.assertEquals('test1',((Contact)sObjManager.mainSObjectList.get(0)).FirstName);
		sObjManager.setSObject(1,new Contact(FirstName='test2'));
		System.assertEquals(2,sObjManager.mainSObjectList.size());
		System.assertEquals('test1',((Contact)sObjManager.mainSObjectList.get(0)).FirstName);
		System.assertEquals('test2',((Contact)sObjManager.mainSObjectList.get(1)).FirstName);
		sObjManager.setSObject(0,new Contact(FirstName='test3'));
		System.assertEquals(2,sObjManager.mainSObjectList.size());
		System.assertEquals('test3',((Contact)sObjManager.mainSObjectList.get(0)).FirstName);
		System.assertEquals('test2',((Contact)sObjManager.mainSObjectList.get(1)).FirstName);
	}
	/**
	 * @description getting sObject from the sObject Manager
	 */
	@isTest
	static void getSObjectTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		try{
			sObjManager.getSObject(0);
			System.assert (false);
		}catch(ListException e) {
			System.assert (true);
		}
		sObjManager.mainSObjectList.add(new Contact());
		System.assertNotEquals(null,sObjManager.getSObject(0));
	}
	/**
	 * @description setting a relationship on the sObject Manager
	 */
	@isTest
	static void setRelationshipTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		sObjManager.setRelationship(0,'contact',new Contact(FirstName='test1'));
		System.assertNotEquals(null,sObjManager.relatedSObjMapList.get('contact'));
		System.assertEquals(1,sObjManager.relatedSObjMapList.get('contact').size());
		System.assertEquals('test1',((Contact)sObjManager.relatedSObjMapList.get('contact').get(0)).FirstName);
		sObjManager.setRelationship(1,'contact',new Contact(FirstName='test2'));
		System.assertEquals(2,sObjManager.relatedSObjMapList.get('contact').size());
		System.assertEquals('test1',((Contact)sObjManager.relatedSObjMapList.get('contact').get(0)).FirstName);
		System.assertEquals('test2',((Contact)sObjManager.relatedSObjMapList.get('contact').get(1)).FirstName);
		sObjManager.setRelationship(0,'contact',new Contact(FirstName='test3'));
		System.assertEquals(2,sObjManager.relatedSObjMapList.get('contact').size());
		System.assertEquals('test3',((Contact)sObjManager.relatedSObjMapList.get('contact').get(0)).FirstName);
		System.assertEquals('test2',((Contact)sObjManager.relatedSObjMapList.get('contact').get(1)).FirstName);
	}
	/**
	 * @description getting a relationship from the sObject Manager
	 */
	@isTest
	static void getRelationshipTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		System.assertEquals(null,sObjManager.getRelationship(0,'contact'));
		System.assertEquals(null,sObjManager.getRelationship(100,'contact'));
		sObjManager.relatedSObjMapList.put('contact',new List<SObject>());
		sObjManager.relatedSObjMapList.put('contact',new List<SObject> {new Contact()});
		System.assertNotEquals(null,sObjManager.getRelationship(0,'contact'));
		System.assertNotEquals(null,sObjManager.getRelationship(0,'ConTacT'));
	}
	/**
	 * @description insert all sObjects of sObject Manager
	 */
	@isTest
	static void insertAllTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		Account acc = new Account(Name='test');
		Contact con = new Contact(LastName='test');
		sObjManager.mainSObjectList.add(con);
		sObjManager.relatedSObjMapList.put('account',new List<SObject> {acc});
		sObjManager.orderedRelationshipList.add('account');
		try {
			sObjManager.insertAll();
			List<Contact> conList = [select LastName, Account.Name from Contact limit 1];
			System.assertNotEquals(null,conList);
			System.assertEquals(1,conList.size());
			System.assertEquals('test',conList.get(0).LastName);
			System.assertEquals('test',conList.get(0).Account.Name);
		}catch(DmlException e) {
			System.assert (true); // if missing required fields
		}
	}
	/**
	 * @description set a child parent relationship on the sObject Manager
	 */
	@isTest
	static void setChildParentRelationshipTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		List<Account> accList = new List<Account> {new Account(Name='test')};
		List<Contact> conList = new List<Contact> {new Contact(LastName='test')};
		try {
			insert accList;
			sObjManager.setChildParentRelationship(conList,accList,'Account');
			System.assertNotEquals(null,conList.get(0).AccountId);
		}catch(DmlException e) {
			System.assert (true); // if missing required fields
		}
	}
	/**
	 * @description add a relationship name on the sObject Manager
	 */
	@isTest
	static void addRelationshipNameTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		sObjManager.addRelationshipName('contact');
		System.assertNotEquals(null,sObjManager.orderedRelationshipList);
		System.assertEquals(1,sObjManager.orderedRelationshipList.size());
		sObjManager.addRelationshipName('contact.account');
		System.assertEquals(2,sObjManager.orderedRelationshipList.size());
		System.assertEquals('contact.account',sObjManager.orderedRelationshipList.get(0));
		System.assertEquals('contact',sObjManager.orderedRelationshipList.get(1));
		sObjManager.addRelationshipName('Contact');
		System.assertEquals(2,sObjManager.orderedRelationshipList.size());
		System.assertEquals('contact.account',sObjManager.orderedRelationshipList.get(0));
		System.assertEquals('contact',sObjManager.orderedRelationshipList.get(1));
	}
	/**
	 * @description insert a list of sObjects
	 */
	@isTest
	static void insertListTest(){
		RS_TestDataFactory_Cmn.SObjectManager sObjManager = new RS_TestDataFactory_Cmn.SObjectManager('Case');
		List<Account> accList = new List<Account> {new Account(Name='test')};
		try {
			sObjManager.insertList(accList,'');
			System.assertNotEquals(null,accList.get(0).Id);
		}catch(DmlException e) {
			System.assert (true); // if missing required fields
		}
	}


	/************************* SObjectFactory tests *************************/
	@isTest
	static void getSObjectFactoryTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		System.assertNotEquals(null,sObjFactory.getSObjectManager());
	}
	@isTest
	static void getSObjectInstanceTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		SObject sObj = sObjFactory.getSObjectInstance(new Map<String,Object>(),false);
		System.assertNotEquals(null,sObj);
		System.assertEquals(Contact.SObjectType,sObj.getSObjectType());
	}
	@isTest
	static void getListSObjectInstanceTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		List<SObject> sObjList = sObjFactory.getListSObjectInstance(new Map<String,Object> {'Account.Description' => 'test'},false,5);
		System.assertNotEquals(null,sObjList);
		System.assertEquals(5,sObjList.size());
		System.assertEquals(Contact.SObjectType,sObjList.get(0).getSObjectType());
		System.assertNotEquals(null,sObjList.get(0).getSObject('Account'));
		System.assertEquals('test',sObjList.get(0).getSObject('Account').get('Description'));
	}
	@isTest
	static void initSObjectInstanceTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		sObjFactory.initSObjectInstance(new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {'Account.Description' => new RS_TestDataFactory_Cmn.FieldDefaultValue('test')},0);
		System.assertNotEquals(null,sObjFactory.getSObjectManager());
		System.assertNotEquals(null,sObjFactory.getSObjectManager().getMainSObjectList());
		System.assertEquals(1,sObjFactory.getSObjectManager().getMainSObjectList().size());
		sObject mainSObj = sObjFactory.getSObjectManager().getMainSObjectList().get(0);
		System.assertNotEquals(null,mainSObj);
		System.assertNotEquals(null,mainSObj.getSObject('Account'));
		System.assertEquals('test',mainSObj.getSObject('Account').get('Description'));
	}
	@isTest
	static void getRelationshipInstanceTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Case.SObjectType);
		SObject sObj = sObjFactory.getRelationshipInstance('Contact.Account',0);
		System.assertNotEquals(null,sObj);
		System.assertEquals(Account.SObjectType,sObj.getSObjectType());
	}
	@isTest
	static void getRelatedSObjectInstanceTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		SObject sObj = sObjFactory.getRelatedSObjectInstance(Contact.SObjectType,'Account','');
		System.assertNotEquals(null,sObj);
		System.assertEquals(Account.SObjectType,sObj.getSObjectType());
	}
	@isTest
	static void getFieldValueFromMapOfValuesTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'Lastname' => new RS_TestDataFactory_Cmn.FieldDefaultValue('Test'),
			'Description' => new RS_TestDataFactory_Cmn.ListFieldDefaultValue(new List<String> {'Test'})
		};

		System.assertEquals('Test',sObjFactory.getFieldValueFromMapOfValues(mapOfValues,'Lastname',0));
		System.assertEquals('Test',sObjFactory.getFieldValueFromMapOfValues(mapOfValues,'Description',0));
		System.assertEquals('Test',sObjFactory.getFieldValueFromMapOfValues(mapOfValues,'Description',1));
		System.assertEquals('Test',sObjFactory.getFieldValueFromMapOfValues(mapOfValues,'Description',2));
		System.assertEquals('Test',sObjFactory.getFieldValueFromMapOfValues(mapOfValues,'Description',3));
	}
	@isTest
	static void putSObjectTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		Contact con = new Contact();
		sObjFactory.putSObject(con,'Account',new Account(Name='Test'),'');
		System.assertEquals('Test',con.Account.Name);
		try{
			sObjFactory.putSObject(con,'Test',new Account(),'');
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	@isTest
	static void putFieldTest(){
		RS_TestDataFactory_Cmn.SObjectFactory sObjFactory = new RS_TestDataFactory_Cmn.SObjectFactory(Contact.SObjectType);
		Contact con = new Contact();
		sObjFactory.putField(con,'FirstName','Test','');
		System.assertEquals('Test',con.FirstName);
		try{
			sObjFactory.putField(con,'Test','Test','');
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}

	/************************* DefaultValueProvider tests *************************/
	@isTest
	static void getDefaultMapOfValuesTest1(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = dvProvider.getDefaultMapOfValues(Opportunity.SObjectType,new Map<String,Object>());
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('name').getValue(0));
		System.assertNotEquals('',mapOfValues.get('stagename').getValue(0));
		System.assertEquals(Date.today(),mapOfValues.get('closedate').getValue(0));
	}
	@isTest
	static void getDefaultMapOfValuesTest2(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = dvProvider.getDefaultMapOfValues(Contract.SObjectType,new Map<String,Object>());
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('account.id').getValue(0));
	}
	@isTest
	static void getDefaultMapOfValuesTest3(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = dvProvider.getDefaultMapOfValues(Contact.SObjectType,new Map<String,Object> {
			'Lastname' => new List<String> {'test1','test2'}
		});
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test1',mapOfValues.get('lastname').getValue(0));
		System.assertEquals('test2',mapOfValues.get('lastname').getValue(1));
	}
	@isTest
	static void getDefaultMapOfValuesTest4(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = dvProvider.getDefaultMapOfValues(Contact.SObjectType,new Map<String,Object> {
			'account' => new Map<String,Object> {
			        'site' => 'test1',
			        'description' => 'test2'
			}
		});
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test1',mapOfValues.get('account.site').getValue(0));
		System.assertEquals('test2',mapOfValues.get('account.description').getValue(1));
	}
	@isTest
	static void getDefaultMapOfValuesTest5(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = dvProvider.getDefaultMapOfValues(Contact.SObjectType,null);
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('lastname').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest1(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue>();
		dvProvider.generateDefaultMapOfValues(Contract.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('account.id').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest2(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'contact.id' => new RS_TestDataFactory_Cmn.FieldDefaultValue(null)
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('contact.lastname').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest3(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'contact.description' => RS_TestDataFactory_Cmn.DEFAULT_VALUE,
			'subject' => RS_TestDataFactory_Cmn.DEFAULT_VALUE
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('contact.lastname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('contact.description').getValue(0));
		System.assertEquals('test0',mapOfValues.get('subject').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest4(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'description' => new RS_TestDataFactory_Cmn.ListFieldDefaultValue(new List<String> {'description1','description2'})
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('description1',mapOfValues.get('description').getValue(0));
		System.assertEquals('description2',mapOfValues.get('description').getValue(1));
	}
	@isTest
	static void generateDefaultMapOfValuesTest5(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'contact.description' => RS_TestDataFactory_Cmn.DEFAULT_VALUE,
			'subject' => RS_TestDataFactory_Cmn.DEFAULT_VALUE
		};
		dvProvider.generateDefaultMapOfValues(Contact.SObjectType,mapOfValues,'contact.');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('contact.lastname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('contact.description').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest6(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'contactid' => RS_TestDataFactory_Cmn.DEFAULT_VALUE
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('contactid'));
		System.assertEquals(null,mapOfValues.get('contact.id').getValue(0));
		System.assertEquals('test0',mapOfValues.get('contact.lastname').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest7(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'asset.contactid' => RS_TestDataFactory_Cmn.DEFAULT_VALUE
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('asset.contactid'));
		System.assertEquals(null,mapOfValues.get('asset.contact.id').getValue(0));
		System.assertEquals('test0',mapOfValues.get('asset.contact.lastname').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest8(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'asset.contact.description' => new RS_TestDataFactory_Cmn.FieldDefaultValue('test0'),
			'asset.parent.contact.description' => new RS_TestDataFactory_Cmn.FieldDefaultValue('test0')
		};
		dvProvider.generateDefaultMapOfValues(Case.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('asset.contactid'));
		System.assertEquals('test0',mapOfValues.get('asset.contact.lastname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('asset.contact.description').getValue(0));
		System.assertEquals(null,mapOfValues.get('asset.parent.contactid'));
		System.assertEquals('test0',mapOfValues.get('asset.parent.contact.lastname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('asset.parent.contact.description').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest9(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new DefaultValueProviderOverride(); // override instance
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'lastname' => new RS_TestDataFactory_Cmn.FieldDefaultValue('test0')
		};
		dvProvider.generateDefaultMapOfValues(Contact.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals('test0',mapOfValues.get('lastname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('firstname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('description').getValue(0));
		System.assertEquals('my_custom_email0@email.com',mapOfValues.get('email').getValue(0));
	}
	@isTest
	static void generateDefaultMapOfValuesTest10(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new DefaultValueProviderOverride(); // override instance
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue>();
		dvProvider.generateDefaultMapOfValues(Contact.SObjectType,mapOfValues,'');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('lastname'));
		System.assertEquals('test0',mapOfValues.get('firstname').getValue(0));
		System.assertEquals('test0',mapOfValues.get('description').getValue(0));
		System.assertEquals('my_custom_email0@email.com',mapOfValues.get('email').getValue(0));
	}
	@isTest
	static void putRelationshipFieldTest1(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue>();
		dvProvider.putRelationshipField(mapOfValues, Schema.SObjectType.Case.Fields.ContactId, '');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('contact.id').getValue(0));
		System.assertEquals('test0',mapOfValues.get('contact.lastname').getValue(0));
	}
	@isTest
	static void putRelationshipFieldTest2(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue>();
		dvProvider.putRelationshipField(mapOfValues, Schema.SObjectType.Case.Fields.ContactId, 'asset.');
		System.assertNotEquals(null,mapOfValues);
		System.assertEquals(null,mapOfValues.get('asset.contact.id').getValue(0));
		System.assertEquals('test0',mapOfValues.get('asset.contact.lastname').getValue(0));
	}
	@isTest
	static void managePersonAccountOrgEnabledTest1(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();

		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue>();
		Set<String> definedRequiredFields = new Set<String>();

		dvProvider.managePersonAccountOrgEnabled(mapOfValues,'',definedRequiredFields);

		System.assertEquals(1, mapOfValues.keySet().size());
		System.assertNotEquals(null, mapOfValues.get('recordtypeid'));
		System.assert (mapOfValues.get('recordtypeid').getValue(0) instanceof Id);
		System.assertEquals(dvProvider.accountDefaultRecordTypeId, (Id)mapOfValues.get('recordtypeid').getValue(0));
		System.assertEquals(1, definedRequiredFields.size());
	}
	@isTest
	static void managePersonAccountOrgEnabledTest2(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Id personAccountRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfos().get(0).getRecordTypeId();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'account.recordtypeid' => new RS_TestDataFactory_Cmn.FieldDefaultValue(personAccountRecordTypeId)
		};
		Set<String> definedRequiredFields = new Set<String>();

		dvProvider.managePersonAccountOrgEnabled(mapOfValues,'account.',definedRequiredFields);

		System.assertEquals(1, mapOfValues.keySet().size());
		System.assertNotEquals(null, mapOfValues.get('account.recordtypeid'));
		System.assert (mapOfValues.get('account.recordtypeid').getValue(0) instanceof Id);
		System.assertEquals(personAccountRecordTypeId, (Id)mapOfValues.get('account.recordtypeid').getValue(0));
		System.assertEquals(1, definedRequiredFields.size());
	}
	@isTest
	static void managePersonAccountOrgEnabledTest3(){
		if(RS_TestDataFactory_Cmn.isPersonAccountEnabled) {
			RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
			Id personAccountRecordTypeId = new List<Id>(dvProvider.personAccountRecordTypes).get(0);
			Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
				'account.recordtypeid' => new RS_TestDataFactory_Cmn.FieldDefaultValue(personAccountRecordTypeId)
			};
			Set<String> definedRequiredFields = new Set<String>();

			dvProvider.managePersonAccountOrgEnabled(mapOfValues,'account.',definedRequiredFields);

			System.assertEquals(1, mapOfValues.keySet().size());
			System.assertNotEquals(null, mapOfValues.get('account.recordtypeid'));
			System.assert (mapOfValues.get('account.recordtypeid').getValue(0) instanceof Id);
			System.assertEquals(personAccountRecordTypeId, (Id)mapOfValues.get('account.recordtypeid').getValue(0));
			System.assertEquals(1, definedRequiredFields.size());
		}
	}
	@isTest
	static void managePersonAccountOrgEnabledTest4(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Id personAccountRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfos().get(0).getRecordTypeId();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'account.recordtypeid' => new RS_TestDataFactory_Cmn.ListFieldDefaultValue(new List<Id> {personAccountRecordTypeId})
		};
		Set<String> definedRequiredFields = new Set<String>();

		try{
			dvProvider.managePersonAccountOrgEnabled(mapOfValues,'account.',definedRequiredFields);
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	@isTest
	static void managePersonAccountOrgEnabledTest5(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> mapOfValues = new Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> {
			'account.recordtypeid' => new RS_TestDataFactory_Cmn.FieldDefaultValue('BAD ID')
		};
		Set<String> definedRequiredFields = new Set<String>();

		try{
			dvProvider.managePersonAccountOrgEnabled(mapOfValues,'account.',definedRequiredFields);
			System.assert (false);
		}catch(RS_TestDataFactory_Cmn.TestDataFactoryException e) {
			System.assert (true);
		}
	}
	@isTest
	static void getDefinedSObjectRequiredFieldsTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Set<String> definedRequiredFields = dvProvider.getDefinedSObjectRequiredFields(Case.SObjectType);
		System.assertNotEquals(null,definedRequiredFields);
	}
	@isTest
	static void getDefinedSObjectOptionalFieldsTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Set<String> definedOptionalFields = dvProvider.getDefinedSObjectOptionalFields(Case.SObjectType);
		System.assertNotEquals(null,definedOptionalFields);
	}
	@isTest
	static void getRelationshipKeySetTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		System.assertEquals(new Set<String> {'contact'},dvProvider.getRelationshipKeySet(new Set<String> {'Contact.AccountId','Contact.Account.ParentId'},''));
		System.assertEquals(new Set<String> {'account'},dvProvider.getRelationshipKeySet(new Set<String> {'Contact.Account.Id','Contact.Account.ParentId','Contact.AccountId'},'Contact.'));
		System.assertEquals(new Set<String> {'parent','user'},dvProvider.getRelationshipKeySet(new Set<String> {'Contact.Account.User.Id','Contact.Account.Parent.Id','Contact.Account.Description'},'Contact.Account.'));
	}
	@isTest
	static void convertMapValueTypesTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Map<String,Object> testMap = new Map<String,Object> {
			'Test0' => 0,
			'  tEst1  ' => 1,
			'TesT2' => new RS_TestDataFactory_Cmn.FieldDefaultValue(2),
			'test3' => new List<String> {'value1','value2'},
			'test4' => new Map<String,Object> {
				'Test1' => 'value1',
				'tesT2 ' => new Map<String,Object> {
					'test1' => 'value2'
				}
			},
			'test5' => new User(Id = UserInfo.getUserId()),
			'test6' => new List<SObject> {new User(Id = null),new User(Id = UserInfo.getUserId())},
			'test7__r' => new User(Id = UserInfo.getUserId())
		};
		Map<String,RS_TestDataFactory_Cmn.IFieldDefaultValue> convertedMap = dvProvider.convertMapValueTypes('',testMap);
		System.assert (convertedMap.keySet().contains('test0'));
		System.assert (convertedMap.keySet().contains('test1'));
		System.assert (convertedMap.keySet().contains('test2'));
		System.assertEquals(0,convertedMap.get('test0').getValue(0));
		System.assertEquals(1,convertedMap.get('test1').getValue(0));
		System.assertEquals(2,convertedMap.get('test2').getValue(0));
		System.assertEquals('value1',convertedMap.get('test3').getValue(0));
		System.assertEquals('value2',convertedMap.get('test3').getValue(1));
		System.assertEquals('value1',convertedMap.get('test4.test1').getValue(0));
		System.assertEquals('value2',convertedMap.get('test4.test2.test1').getValue(0));
		System.assertEquals(UserInfo.getUserId(),convertedMap.get('test5id').getValue(0));
		System.assertEquals(null,convertedMap.get('test6id').getValue(0));
		System.assertEquals(UserInfo.getUserId(),convertedMap.get('test7__c').getValue(1));
	}
	@isTest
	static void convertSetToLowerCaseTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		Set<String> testSet = new Set<String> {
			'Test0',
			'  tEst1  ',
			'Test2'
		};
		Set<String> convertedSet = dvProvider.convertSetToLowerCase(testSet);
		System.assert (convertedSet.contains('test0'));
		System.assert (convertedSet.contains('test1'));
		System.assert (convertedSet.contains('test2'));
	}
	@isTest
	static void getSFDefaultPicklistValueTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		String defaultValue = dvProvider.getSFDefaultPicklistValue(Contract.fields.Status.getDescribe());
		System.assertNotEquals(null,defaultValue);
		System.assertNotEquals('',defaultValue);
	}
	@isTest
	static void isDefaultValueRequiredTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		System.assertEquals(true,dvProvider.isDefaultValueRequired(Contact.fields.Lastname.getDescribe()));
		System.assertEquals(false,dvProvider.isDefaultValueRequired(Contact.fields.OwnerId.getDescribe()));
	}
	@isTest
	static void getDefaultValueTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		System.assertEquals(Blob.valueOf('0'),dvProvider.getDefaultValue(Attachment.SObjectType.getDescribe(),Attachment.fields.Body.getDescribe(),0)); // base64
		System.assertEquals(false,dvProvider.getDefaultValue(Campaign.SObjectType.getDescribe(),Campaign.fields.IsActive.getDescribe(),0)); // checkbox
		System.assertEquals(0,dvProvider.getDefaultValue(Lead.SObjectType.getDescribe(),Lead.fields.AnnualRevenue.getDescribe(),0)); // currency
		System.assertEquals(Date.today(),dvProvider.getDefaultValue(Account.SObjectType.getDescribe(),Account.fields.LastActivityDate.getDescribe(),0)); // date
		System.assertEquals(Datetime.now(),dvProvider.getDefaultValue(Account.SObjectType.getDescribe(),Account.fields.CreatedDate.getDescribe(),0)); // datetime
		System.assertEquals('test0@email.com',dvProvider.getDefaultValue(Contact.SObjectType.getDescribe(),Contact.fields.Email.getDescribe(),0)); // email
		// no standard geolocation field
		System.assertEquals(0,dvProvider.getDefaultValue(Attachment.SObjectType.getDescribe(),Attachment.fields.BodyLength.getDescribe(),0)); // number
		System.assertEquals(0,dvProvider.getDefaultValue(Asset.SObjectType.getDescribe(),Asset.fields.Quantity.getDescribe(),0)); // number
		System.assertEquals(0,dvProvider.getDefaultValue(Opportunity.SObjectType.getDescribe(),Opportunity.fields.Probability.getDescribe(),0)); // percent
		System.assertEquals('01 23 45 67 89',dvProvider.getDefaultValue(Contact.SObjectType.getDescribe(),Contact.fields.Phone.getDescribe(),0)); // phone
		System.assertNotEquals('',dvProvider.getDefaultValue(Account.SObjectType.getDescribe(),Account.fields.Type.getDescribe(),0)); //  picklist
		// no standard multipicklist field
		System.assertEquals('test0',dvProvider.getDefaultValue(Contact.SObjectType.getDescribe(),Contact.fields.FirstName.getDescribe(),0));  // text
		System.assertEquals('test0',dvProvider.getDefaultValue(Account.SObjectType.getDescribe(),Account.fields.Description.getDescribe(),0)); // textarea
		// no standard time field
		System.assertEquals('http://test0.com',dvProvider.getDefaultValue(Account.SObjectType.getDescribe(),Account.fields.Website.getDescribe(),0));
		System.assertEquals(null,dvProvider.getDefaultValue(null,null,0));
	}
	@isTest
	static void getTypeDefaultValueTest(){
		RS_TestDataFactory_Cmn.DefaultValueProvider dvProvider = new RS_TestDataFactory_Cmn.DefaultValueProvider();
		System.assertEquals(Blob.valueOf('0'),dvProvider.getBase64DefaultValue(null,null,0));
		System.assertEquals(false,dvProvider.getCheckboxDefaultValue(null,null,0));
		System.assertEquals(0,dvProvider.getCurrencyDefaultValue(null,null,0));
		System.assertEquals(Date.today(),dvProvider.getDateDefaultValue(null,null,0));
		System.assertEquals(Datetime.now(),dvProvider.getDateTimeDefaultValue(null,null,0));
		System.assertEquals('test0@email.com',dvProvider.getEmailDefaultValue(null,null,0));
		System.assertNotEquals(null,dvProvider.getGeolocationDefaultValue(null,null,0));
		System.assertEquals(0,dvProvider.getNumberDefaultValue(null,null,0));
		System.assertEquals(0,dvProvider.getPercentDefaultValue(null,null,0));
		System.assertEquals('01 23 45 67 89',dvProvider.getPhoneDefaultValue(null,null,0));
		System.assertEquals(null,dvProvider.getPicklistDefaultValue(null,null,0));
		System.assertNotEquals('',dvProvider.getPicklistDefaultValue(Account.SObjectType.getDescribe(),Account.fields.Type.getDescribe(),0));
		System.assertEquals('test0',dvProvider.getTextDefaultValue(null,null,0));
		System.assertEquals(null,dvProvider.getMultiPicklistDefaultValue(null,null,0));
		System.assertNotEquals('',dvProvider.getMultiPicklistDefaultValue(Account.SObjectType.getDescribe(),Account.fields.Type.getDescribe(),0));
		System.assertEquals('test0',dvProvider.getTextDefaultValue(null,null,0));
		System.assertEquals('test0',dvProvider.getTextAreaDefaultValue(null,null,0));
		System.assertEquals(Time.newInstance(12, 0, 0, 0),dvProvider.getTimeDefaultValue(null,null,0));
		System.assertEquals('http://test0.com',dvProvider.getURLDefaultValue(null,null,0));
	}

	/************************* AutoFieldDefaultValue inner class tests *************************/
	@isTest
	static void getValueTest1(){
		RS_TestDataFactory_Cmn.IFieldDefaultValue autoFieldDV = new RS_TestDataFactory_Cmn.AutoFieldDefaultValue();
		System.assertEquals(null,autoFieldDV.getValue(0));
	}

	/************************* FieldDefaultValue inner class tests *************************/
	@isTest
	static void getValueTest2(){
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV1 = new RS_TestDataFactory_Cmn.FieldDefaultValue(null);
		System.assertEquals(null,(new RS_TestDataFactory_Cmn.FieldDefaultValue(null)).getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV2 = new RS_TestDataFactory_Cmn.FieldDefaultValue('test');
		System.assertEquals('test',fieldDV2.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV3 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Attachment.SObjectType.getDescribe(),Attachment.fields.Body.getDescribe());
		System.assertEquals(Blob.valueOf('0'),fieldDV3.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV4 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Campaign.SObjectType.getDescribe(),Campaign.fields.IsActive.getDescribe());
		System.assertEquals(false,fieldDV4.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV5 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Lead.SObjectType.getDescribe(),Lead.fields.AnnualRevenue.getDescribe());
		System.assertEquals(0,fieldDV5.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV6 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Account.SObjectType.getDescribe(),Account.fields.LastActivityDate.getDescribe());
		System.assertEquals(Date.today(),fieldDV6.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV7 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Account.SObjectType.getDescribe(),Account.fields.CreatedDate.getDescribe());
		System.assertEquals(Datetime.now(),fieldDV7.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV8 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Asset.SObjectType.getDescribe(),Asset.fields.Quantity.getDescribe());
		System.assertEquals(0,fieldDV8.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV9 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Contact.SObjectType.getDescribe(),Contact.fields.Email.getDescribe());
		System.assertEquals('test0@email.com',fieldDV9.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV10 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Account.SObjectType.getDescribe(),Account.fields.Id.getDescribe());
		System.assertEquals(null,fieldDV10.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV11 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Attachment.SObjectType.getDescribe(),Attachment.fields.BodyLength.getDescribe());
		System.assertEquals(0,fieldDV11.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV12 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Opportunity.SObjectType.getDescribe(),Opportunity.fields.Probability.getDescribe());
		System.assertEquals(0,fieldDV12.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV13 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Contact.SObjectType.getDescribe(),Contact.fields.Phone.getDescribe());
		System.assertEquals('01 23 45 67 89',fieldDV13.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV14 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Account.SObjectType.getDescribe(),Account.fields.Type.getDescribe());
		System.assertNotEquals('',fieldDV14.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV15 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Contact.SObjectType.getDescribe(),Contact.fields.FirstName.getDescribe());
		System.assertEquals('test0',fieldDV15.getValue(0));
		RS_TestDataFactory_Cmn.IFieldDefaultValue fieldDV16 = new RS_TestDataFactory_Cmn.FieldDefaultValue(new RS_TestDataFactory_Cmn.DefaultValueProvider(),Account.SObjectType.getDescribe(),Account.fields.Description.getDescribe());
		System.assertEquals('test0',fieldDV16.getValue(0));
	}
	@isTest
	static void getValueTest3(){
		List<String> listValues = new List<String> {'test0','test1'};
		RS_TestDataFactory_Cmn.ListFieldDefaultValue listFieldDV = new RS_TestDataFactory_Cmn.ListFieldDefaultValue(listValues);
		System.assertEquals(2,listFieldDV.size());
		System.assertEquals('test0',listFieldDV.getValue(0));
		System.assertEquals('test1',listFieldDV.getValue(1));
	}

	/* ============================================================================================= */
	/* ======================================  inner test classes ================================== */
	/* ============================================================================================= */
	public class DefaultValueProviderOverride extends RS_TestDataFactory_Cmn.DefaultValueProvider {
		public override Set<String> defineSObjectRequiredFields(Schema.SObjectType sObjectType){
			if(sObjectType == Contact.SObjectType) {
				return new Set<String> {
					       ' FirstName ',
					       'Description',
					       'EmaiL'
				};
			}
			return null;
		}

		public override Set<String> defineSObjectOptionalFields(Schema.SObjectType sObjectType){
			if(sObjectType == Contact.SObjectType) {
				return new Set<String> {
					       'Lastname'
				};
			}
			return null;
		}

		public override String getEmailDefaultValue(Schema.DescribeSObjectResult sObjectDesc, Schema.DescribeFieldResult fieldDesc, Integer recordIndex){
			return 'my_custom_email'+recordIndex.format()+'@email.com';
		}
	}


	/************************* Util methods tests *************************/
	@isTest
	static void getFieldTokensMapTest(){
		Map<String, Schema.SObjectField> accountFieldMap = RS_TestDataFactory_Cmn.getFieldTokensMap(Account.SObjectType);
		System.assertNotEquals(null,accountFieldMap);
		System.assertEquals(1,RS_TestDataFactory_Cmn.mapOfFieldTokensMap.size());
	}
	@isTest
	static void getFieldNameFromRelationshipNameTest(){
		System.assertEquals('customrelationship__c',RS_TestDataFactory_Cmn.getFieldNameFromRelationshipName('customrelationshiP__r'));
		System.assertEquals('standardrelationshipid',RS_TestDataFactory_Cmn.getFieldNameFromRelationshipName('standardRelationshiP'));
	}
	@isTest
	static void mergeValueTest(){
		System.assertEquals(null,RS_TestDataFactory_Cmn.mergeValue(null,'i','101'));
		System.assertEquals('test101',RS_TestDataFactory_Cmn.mergeValue('test{!i}','i','101'));
		System.assertEquals('test101',RS_TestDataFactory_Cmn.mergeValue('test{!iD}','id','101'));
		System.assertEquals('test101',RS_TestDataFactory_Cmn.mergeValue('test{!Id}','ID','101'));
	}
	@isTest
	static void formatErrorMessageTest(){
		System.assertEquals('test1',RS_TestDataFactory_Cmn.formatErrorMessage('test{0}',new List<String> {'1'},null));
		System.assertEquals('test12',RS_TestDataFactory_Cmn.formatErrorMessage('test{0}{1}',new List<String> {'1','2'},null));
		System.assertEquals('test1\nOriginal error message : Error',RS_TestDataFactory_Cmn.formatErrorMessage('test{0}',new List<String> {'1'},'Error'));
	}

}