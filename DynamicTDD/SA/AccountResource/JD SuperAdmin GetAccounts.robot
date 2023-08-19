*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        POC
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-SuperadminGetAccount-1
	Comment  Get Account Data  when  id-eq=${id}  uid-eq=${uid}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${uid} =  get_uid  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
    
# ***Comment***

JD-TC-SuperadminGetAccount-2
	Comment  Get Account Data  when  id-eq=${id}  businessName-eq=${busName}
        
        ${resp}=   Provider Login  ${PUSERNAME1}  ${PASSWORD} 
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${account_id}  ${resp.json()['id']}
        Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
        Set Suite Variable  ${busName}  ${resp.json()['businessName']}

        ${resp}=   Provider Logout 
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-eq=${id}  businessName-eq=${busName}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${busName}
      

# *** Test Cases ***

JD-TC-SuperadminGetAccount-3
        Comment  Get Account Data when id-eq=${id}   license-eq=${vari}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts    id-eq=${id}  license-eq=${vari}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}
      


JD-TC-SuperadminGetAccount-4
        Comment  Get Account Data when id-eq=${id}  serviceSector-eq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  serviceSector-eq=1
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        
# ***Comment***   

JD-TC-SuperadminGetAccount-5
        Comment  Get Account Data when id-eq=${id}  serviceSubSector-eq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  serviceSubSector-eq=1
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
       

JD-TC-SuperadminGetAccount-6
        Comment  Get Account Data when id-eq=${id} accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-eq=${id}  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
    


JD-TC-SuperadminGetAccount-7
        Comment  Get Account Data when id-eq=${id}  accntStatus-eq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}   accntStatus-eq=ACTIVE
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
          

JD-TC-SuperadminGetAccount-8
       Comment  Get Account Data when id-eq=${id}  claimStatus-eq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  claimStatus-eq=Claimed
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
       

JD-TC-SuperadminGetAccount-9
	Comment  Get Account Data when id-eq=${id}  createdDate-eq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate}
        ${resp} =  Get Accounts    id-eq=${id}  createdDate-eq=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
     



JD-TC-SuperadminGetAccount-10
        Comment  Get Account Data when id-eq=${id}  verifiedLevel-eq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  verifiedLevel-eq=NONE
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
     


JD-TC-SuperadminGetAccount-11
	Comment  Get Account Data when id-eq=${id}  searchEnabled-eq=true
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  searchEnabled-eq=true
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
       

JD-TC-SuperadminGetAccount-12
        Comment  Get Account Data when businessName-eq=Anjali Health Care  license-eq=${vari}  id-eq=${id}  
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care   license-eq=${vari}   id-eq=${id}   
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       


JD-TC-SuperadminGetAccount-13
        Comment  Get Account Data when businessName-eq=Anjali Health Care  serviceSector-eq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care  serviceSector-eq=1
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1  
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
       

JD-TC-SuperadminGetAccount-14
        Comment  Get Account Data when businessName-eq=Anjali Health Care   serviceSubSector-eq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care  serviceSubSector-eq=1
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
       

JD-TC-SuperadminGetAccount-15   
       Comment  Get Account Data when businessName-eq=Anjali Health Care  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care   accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
    

JD-TC-SuperadminGetAccount-16
        Comment  Get Account Data when businessName-eq=Anjali Health Care  accntStatus-eq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care  accntStatus-eq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
       

JD-TC-SuperadminGetAccount-17
        Comment  Get Account Data when businessName-eq=Anjali Health Care  claimStatus-eq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-eq=Anjali Health Care  claimStatus-eq=Claimed
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        

JD-TC-SuperadminGetAccount-18
        Comment  Get Account Data when businessName-eq=Anjali Health Care  createdDate-eq=${currentDate}  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts    businessName-eq=Anjali Health Care  createdDate-eq=${currentDate}  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        

JD-TC-SuperadminGetAccount-19
        Comment  Get Account Data when businessName-eq=Anjali Health Care  verifiedLevel-eq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-eq=Anjali Health Care  verifiedLevel-eq=NONE
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
       

JD-TC-SuperadminGetAccount-20
	Comment  Get Account Data when businessName-eq=Anjali Health Care  searchEnabled-eq=true
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-eq=Anjali Health Care   searchEnabled-eq=true
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
       


JD-TC-SuperadminGetAccount-21
        Comment  Get Account Data when license-eq=${vari}  serviceSector-eq=1   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${resp} =  Get Accounts   license-eq=${vari}  serviceSector-eq=1   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}   ${vari}
       Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
 	Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      



JD-TC-SuperadminGetAccount-22
        Comment  Get Account Data when license-eq=${vari}  serviceSubSector-eq=1  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${resp} =  Get Accounts    license-eq=${vari}  serviceSubSector-eq=1  id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     
         

JD-TC-SuperadminGetAccount-23  
       Comment  Get Account Data when license-eq=${vari}   accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${resp} =  Get Accounts    license-eq=${vari}    accountLinkedPhoneNumber-eq=${PUSERNAME1} 
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
     



JD-TC-SuperadminGetAccount-24
        Comment  Get Account Data when license-eq=${vari}  accntStatus-eq=ACTIVE  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${resp} =  Get Accounts   license-eq=${vari}  accntStatus-eq=ACTIVE   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}   ${vari} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
 



JD-TC-SuperadminGetAccount-25
        Comment  Get Account Data when license-eq=${vari}  claimStatus-eq=Claimed   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${resp} =  Get Accounts  license-eq=${vari}  claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     


JD-TC-SuperadminGetAccount-26
        Comment  Get Account Data when license-eq=${vari}  createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   license-eq=${vari}  createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      



JD-TC-SuperadminGetAccount-27
        Comment  Get Account Data when license-eq=${vari}   verifiedLevel-eq=NONE   id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  license-eq=${vari}  verifiedLevel-eq=NONE    id-eq=${id} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}   NONE  
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
       
        
JD-TC-SuperadminGetAccount-28
	Comment  Get Account Data when license-eq=${vari}   searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages
        Set Test Variable  ${vari}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  license-eq=${vari}   searchEnabled-eq=true    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
   

JD-TC-SuperadminGetAccount-29
        Comment  Get Account Data when serviceSector-eq=1  serviceSubSector-eq=1   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-eq=1  serviceSubSector-eq=1    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-30 
       Comment  Get Account Data when serviceSector-eq=1  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-eq=1  accountLinkedPhoneNumber-eq=${PUSERNAME1}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-31
        Comment  Get Account Data when serviceSector-eq=1  accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=1   accntStatus-eq=ACTIVE   id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}   1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
         

JD-TC-SuperadminGetAccount-32
        Comment  Get Account Data when serviceSector-eq=1  claimStatus-eq=Claimed   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=1    claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
       

JD-TC-SuperadminGetAccount-33
        Comment  Get Account Data when serviceSector-eq=1  createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSector-eq=1   createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-34
        Comment  Get Account Data when  serviceSector-eq=1  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=1  verifiedLevel-eq=NONE   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      
        
JD-TC-SuperadminGetAccount-35
	Comment  Get Account Data when serviceSector-eq=1  searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSector-eq=1   searchEnabled-eq=true   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-36
        Comment  Get Account Data when serviceSubSector-eq=1  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSubSector-eq=1  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}


JD-TC-SuperadminGetAccount-37
        Comment  Get Account Data when serviceSubSector-eq=1   accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=1  accntStatus-eq=ACTIVE  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}   1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       


JD-TC-SuperadminGetAccount-38 
        Comment  Get Account Data when serviceSubSector-eq=1  claimStatus-eq=Claimed  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=1  claimStatus-eq=Claimed    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     

JD-TC-SuperadminGetAccount-39
        Comment  Get Account Data when serviceSubSector-eq=1  createdDate-eq=${currentDate}  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSubSector-eq=1  createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       

JD-TC-SuperadminGetAccount-40
        Comment  Get Account Data when  serviceSubSector-eq=1  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=1  verifiedLevel-eq=NONE    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
      
        
JD-TC-SuperadminGetAccount-41
	Comment  Get Account Data when serviceSubSector-eq=1  searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSubSector-eq=1   searchEnabled-eq=true  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
       

JD-TC-SuperadminGetAccount-42
	Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}    accntStatus-eq=ACTIVE  id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}   
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}  
      

JD-TC-SuperadminGetAccount-43
        Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   claimStatus-eq=Claimed  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}   claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      



JD-TC-SuperadminGetAccount-44
        Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}    createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}   createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
  

JD-TC-SuperadminGetAccount-45
        Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   verifiedLevel-eq=NONE  id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}   verifiedLevel-eq=NONE    id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     
        
JD-TC-SuperadminGetAccount-46
	Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   searchEnabled-eq=true   id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}   searchEnabled-eq=true   id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        

JD-TC-SuperadminGetAccount-47
        Comment  Get Account Data when  accntStatus-eq=ACTIVE  claimStatus-eq=Claimed   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-eq=ACTIVE  claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE 
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       


JD-TC-SuperadminGetAccount-48
        Comment  Get Account Data when  accntStatus-eq=ACTIVE   createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accntStatus-eq=ACTIVE  createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}   1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}   ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
  

JD-TC-SuperadminGetAccount-49
        Comment  Get Account Data when  accntStatus-eq=ACTIVE   verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-eq=ACTIVE  verifiedLevel-eq=NONE   id-eq=${id}
   	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}   ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       
        
JD-TC-SuperadminGetAccount-50
	Comment  Get Account Data when  accntStatus-eq=ACTIVE  searchEnabled-eq=true   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-eq=ACTIVE  searchEnabled-eq=true    id-eq=${id}
   	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 

        

JD-TC-SuperadminGetAccount-51
        Comment  Get Account Data when  claimStatus-eq=Claimed   createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   claimStatus-eq=Claimed   createdDate-eq=${currentDate}   id-eq=${id}
   	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}   Claimed 
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}


JD-TC-SuperadminGetAccount-52
        Comment  Get Account Data when   claimStatus-eq=Claimed   verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-eq=Claimed   verifiedLevel-eq=NONE   id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed 
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     
        
JD-TC-SuperadminGetAccount-53
	Comment  Get Account Data when  claimStatus-eq=Claimed  searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-eq=Claimed  searchEnabled-eq=true  id-eq=${id}
   	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed 
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     



JD-TC-SuperadminGetAccount-54
	Comment  Get Account Data when createdDate-eq=${currentDate}  accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate}  
        ${resp} =  Get Accounts    createdDate-eq=${currentDate}  accntStatus-eq=ACTIVE   id-eq=${id}
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
     

JD-TC-SuperadminGetAccount-55
	Comment  Get Account Data when createdDate-eq=${currentDate}  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate}
        ${resp} =  Get Accounts    createdDate-eq=${currentDate}  verifiedLevel-eq=NONE   id-eq=${id}
    	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       

JD-TC-SuperadminGetAccount-56
	Comment  Get Account Data when createdDate-eq=${currentDate}  searchEnabled-eq=true   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    createdDate-eq=${currentDate}  searchEnabled-eq=true  id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}   ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       

JD-TC-SuperadminGetAccount-57
	Comment  Get Account Data when  verifiedLevel-eq=NONE  searchEnabled-eq=true   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   verifiedLevel-eq=NONE  searchEnabled-eq=true   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     

JD-TC-SuperadminGetAccount-58
        Comment  Get Account Data when businessName-eq=Anjali Health Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  businessName-eq=Anjali Health Care
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =   Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  Anjali Health Care
     

JD-TC-SuperadminGetAccount-59
	Comment  Get Account Data when createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =  Get Accounts  createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     

JD-TC-SuperadminGetAccount-60
	Comment  Get Account Data when id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id} 
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-61
        Comment  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}  
        ${resp}=  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp}=  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count}=  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        

JD-TC-SuperadminGetAccount-62
	Comment  Get Account Data when  uid-eq=${uid}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${uid} =  get_uid  ${PUSERNAME1}
        ${resp} =  Get Accounts     uid-eq=${uid}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['uniqueId']}  ${uid}
   



JD-TC-SuperadminGetAccount-63
	Comment  Get Account Data when accntStatus-eq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   accntStatus-eq=ACTIVE
        Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-64
	Comment  Get Account Data when  serviceSubSector-eq=1 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    serviceSubSector-eq=1 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  1
       

JD-TC-SuperadminGetAccount-65
	Comment  Get Account Data when serviceSector-eq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   serviceSector-eq=1
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  1
        

JD-TC-SuperadminGetAccount-66
	Comment  Get Account Data when  license-eq=${vari}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts   license-eq=${vari}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${vari}
        

JD-TC-SuperadminGetAccount-67
	Comment  Get Account Data when   claimStatus-eq=Claimed 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   claimStatus-eq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        

JD-TC-SuperadminGetAccount-68
	Comment  Get Account Data when  verifiedLevel-eq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  verifiedLevel-eq=NONE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        

JD-TC-SuperadminGetAccount-69
	Comment  Get Account Data when    searchEnabled-eq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    searchEnabled-eq=false
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  False
        

JD-TC-SuperadminGetAccount-70
	Comment  Get Account Data  when  id-neq=${id}  uid-neq=${uid}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${uid} =  get_uid  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-eq=${id} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-71
	Comment  Get Account Data  when  id-neq=${id}  businessName-neq=Anjali Health Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-neq=${id}  businessName-neq=Anjali Health Care
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-72
        Comment  Get Account Data when id-neq=${id}   license-neq=${vari} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  license-neq=${vari} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-73
        Comment  Get Account Data when id-neq=${id}  serviceSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  serviceSector-neq=1
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-74
        Comment  Get Account Data when id-neq=${id}  serviceSubSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  serviceSubSector-neq=1
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-75
        Comment  Get Account Data when id-neq=${id} accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-eq=${id}  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-76
        Comment  Get Account Data when id-neq=${id}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}   accntStatus-neq=ACTIVE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       
  

JD-TC-SuperadminGetAccount-77
       Comment  Get Account Data when id-neq=${id}  claimStatus-neq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  claimStatus-eq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-78
	Comment  Get Account Data when id-neq=${id}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =  Get Accounts    id-neq=${id}  createdDate-neq=${currentDate}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-79
        Comment  Get Account Data when id-neq=${id}  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  verifiedLevel-eq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
    


JD-TC-SuperadminGetAccount-80
	Comment  Get Account Data when id-neq=${id}  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
      


JD-TC-SuperadminGetAccount-81
        Comment  Get Account Data when businessName-neq=Anjali Health Care  license-neq=${vari}   id-neq=${id}  
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts   businessName-neq=Anjali Health Care  license-neq=${vari}     id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200 
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-82
        Comment  Get Account Data when businessName-neq=Anjali Health Care  serviceSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-neq=Anjali Health Care  serviceSector-neq=1
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-83
        Comment  Get Account Data when businessName-neq=Anjali Health Care   serviceSubSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=Anjali Health Care  serviceSubSector-neq=1
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-84   
       Comment  Get Account Data when businessName-neq=Anjali Health Care  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=Anjali Health Care  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
  	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
        

JD-TC-SuperadminGetAccount-85
        Comment  Get Account Data when businessName-neq=Anjali Health Care  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=Anjali Health Care  accntStatus-neq=ACTIVE
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
    

JD-TC-SuperadminGetAccount-86
        Comment  Get Account Data when businessName-neq=Anjali Health Care  claimStatus-neq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-neq=Anjali Health Care  claimStatus-neq=Claimed
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-87
        Comment  Get Account Data when businessName-neq=Anjali Health Care  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts    businessName-neq=Anjali Health Care  createdDate-neq=${currentDate}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     


JD-TC-SuperadminGetAccount-88
        Comment  Get Account Data when businessName-neq=Anjali Health Care  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-neq=Anjali Health Care  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-89
	Comment  Get Account Data when businessName-neq=Anjali Health Care  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-neq=Anjali Health Care   searchEnabled-neq=false
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-90
        Comment  Get Account Data when license-neq=${vari}   serviceSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts   license-neq=${vari}  serviceSector-neq=1
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-91
        Comment  Get Account Data when license-neq=${vari}  serviceSubSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts    license-neq=${vari}  serviceSubSector-neq=1
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-92
       Comment  Get Account Data when license-neq=${vari}  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts    license-neq=${vari}   accountLinkedPhoneNumber-neq=${PUSERNAME1}
  	Should Be Equal As Strings  ${resp.status_code}  200 
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-93
        Comment  Get Account Data when license-neq=${vari}  accntStatus-neq=ACTIVE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts   license-neq=${vari}   accntStatus-neq=ACTIVE    id-neq=${id}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-94
        Comment  Get Account Data when license-neq=${vari}  claimStatus-neq=Claimed   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts  license-neq=${vari}  claimStatus-neq=Claimed
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-95
        Comment  Get Account Data when license-neq=${vari}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   license-neq=${vari}  createdDate-neq=${currentDate}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-96
        Comment  Get Account Data when license-neq=${vari}   verifiedLevel-neq=NONE   id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts  license-neq=${vari}  verifiedLevel-neq=NONE   id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-97
	Comment  Get Account Data when license-neq=${vari}  searchEnabled-neq=false   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  
        ${resp} =  Get Accounts  license-neq=${vari}  searchEnabled-neq=false   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
 

JD-TC-SuperadminGetAccount-98
        Comment  Get Account Data when serviceSector-neq=1  serviceSubSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-neq=1  serviceSubSector-neq=1
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-99
       Comment  Get Account Data when serviceSector-neq=1  accountLinkedPhoneNumber-neq=${PUSERNAME1}    id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-neq=1  accountLinkedPhoneNumber-neq=${PUSERNAME1}   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-100
        Comment  Get Account Data when serviceSector-neq=1  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=1   accntStatus-eq=ACTIVE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   

JD-TC-SuperadminGetAccount-101
        Comment  Get Account Data when serviceSector-neq=1  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-neq=1    claimStatus-neq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   

JD-TC-SuperadminGetAccount-102
        Comment  Get Account Data when serviceSector-neq=1  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSector-neq=1  createdDate-neq=${currentDate}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
	

JD-TC-SuperadminGetAccount-103
        Comment  Get Account Data when  serviceSector-neq=1  verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-neq=1  verifiedLevel-neq=NONE    id-neq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
  
        
JD-TC-SuperadminGetAccount-104
	Comment  Get Account Data when serviceSector-neq=1  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSector-neq=1   searchEnabled-neq=false
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     
     
JD-TC-SuperadminGetAccount-105
        Comment  Get Account Data when serviceSubSector-neq=1  accountLinkedPhoneNumber-neq=${PUSERNAME1}    id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSubSector-neq=1  accountLinkedPhoneNumber-neq=${PUSERNAME1}   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-106
        Comment  Get Account Data when serviceSubSector-neq=1 accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=1  accntStatus-neq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-107
        Comment  Get Account Data when serviceSubSector-neq=1  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=1  claimStatus-neq=Claimed   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True
    

JD-TC-SuperadminGetAccount-108
        Comment  Get Account Data when serviceSubSector-neq=1  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSubSector-neq=1  createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   
     

JD-TC-SuperadminGetAccount-109
        Comment  Get Account Data when  serviceSubSector-neq=1  verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=1  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   
        
JD-TC-SuperadminGetAccount-110
	Comment  Get Account Data when serviceSubSector-neq=1  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSubSector-neq=1   searchEnabled-neq=false   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-111
	Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   accntStatus-neq=ACTIVE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}  accntStatus-neq=ACTIVE  id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-112
        Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   claimStatus-neq=Claimed  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   claimStatus-neq=Claimed   id-neq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
 
JD-TC-SuperadminGetAccount-113
        Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}    createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
  

JD-TC-SuperadminGetAccount-114
        Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}    verifiedLevel-neq=NONE  id-neq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   verifiedLevel-neq=NONE   id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     
        
JD-TC-SuperadminGetAccount-115
	Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   searchEnabled-neq=false   id-neq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   searchEnabled-neq=false   id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-116
        Comment  Get Account Data when  accntStatus-neq=ACTIVE  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  claimStatus-neq=Claimed
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-117
        Comment  Get Account Data when  accntStatus-neq=ACTIVE   createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accntStatus-neq=ACTIVE  createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-118
        Comment  Get Account Data when  accntStatus-neq=ACTIVE   verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  verifiedLevel-neq=NONE  id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-119
	Comment  Get Account Data when  accntStatus-neq=ACTIVE  searchEnabled-neq=false   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  searchEnabled-neq=false   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-120
        Comment  Get Account Data when  claimStatus-neq=Claimed   createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate}=  get_date
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   claimStatus-neq=Claimed   createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-121
        Comment  Get Account Data when   claimStatus-neq=Claimed   verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-neq=Claimed   verifiedLevel-neq=NONE   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
        
JD-TC-SuperadminGetAccount-122
	Comment  Get Account Data when  claimStatus-neq=Claimed  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-neq=Claimed  searchEnabled-neq=false    id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
        
JD-TC-SuperadminGetAccount-123
	Comment  Get Account Data when createdDate-neq=${currentDate}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}  accntStatus-neq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}   True 
       

JD-TC-SuperadminGetAccount-124
	Comment  Get Account Data when createdDate-neq=${currentDate}  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-125
	Comment  Get Account Data when createdDate-neq=${currentDate}  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}   searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-126
	Comment  Get Account Data when  verifiedLevel-neq=NONE  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   verifiedLevel-neq=NONE  searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-127
	Comment  Get Account Data when  uid-neq=${uid}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${uid} =  get_uid  ${PUSERNAME1}
        ${resp} =  Get Accounts     uid-neq=${uid}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      


JD-TC-SuperadminGetAccount-128
	Comment  Get Account Data when  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-129
        Comment  Get Account Data when businessName-neq=Anjali Health Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  businessName-neq=Anjali Health Care
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =   Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
    


JD-TC-SuperadminGetAccount-130
	Comment  Get Account Data when  license-neq=${vari} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  ProviderLogin   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${licence} =  Get Licensable Packages  
        Set Test Variable   ${vari}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}   
        ${resp} =  Get Accounts   license-neq=${vari}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-131
        Comment  Get Account Data when serviceSector-neq=1
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   serviceSector-neq=1
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-132
	Comment  Get Account Data when  serviceSubSector-neq=1 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    serviceSubSector-neq=1 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-133
        Comment  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}  
        ${resp}=  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp}=  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}  
	Should Be Equal As Strings  ${resp.status_code}  200
	${count}=  Get Length  ${resp.json()}  
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       
JD-TC-SuperadminGetAccount-134
	Comment  Get Account Data when accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True
       
JD-TC-SuperadminGetAccount-135
	Comment  Get Account Data when   claimStatus-neq=Claimed 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   claimStatus-neq=Claimed
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-136
	Comment  Get Account Data when createdDate-eq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  createdDate-neq=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
        
JD-TC-SuperadminGetAccount-137
	Comment  Get Account Data when  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  verifiedLevel-eq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-138
	Comment  Get Account Data when    searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    searchEnabled-neq=false
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-139
        Comment  Get Account Data when businessName-like=Anjali
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Anjali
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-140
        Comment  Get Account Data when businessName-like=Health
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Health
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-141
        Comment  Get Account Data when businessName-like=Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Care
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-142
        Comment  Get Account Data when id-gt=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
	${resp} =  Get Accounts   id-gt=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-143
        Comment  Get Account Data when id-lt=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-lt=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-144
        Comment  Get Account Data when id-le=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-le=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	
JD-TC-SuperadminGetAccount-145
        Comment  Get Account Data when id-ge=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-ge=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 


JD-TC-SuperadminGetAccount-146
        Comment  Get Account Data when createdDate-gt=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-gt=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${len} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  0
	

JD-TC-SuperadminGetAccount-147
        Comment  Get Account Data when createdDate-lt=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-lt=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-148
        Comment  Get Account Data when createdDate-ge=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-ge=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	
JD-TC-SuperadminGetAccount-149
        Comment  Get Account Data when  createdDate-le=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-le=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	


JD-TC-SuperadminGetAccount-150
	Comment  Get Account Data when  accountstatus=INACTIVE
        ${resp} =   SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =   Get Accounts  accntStatus-eq=INACTIVE  
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  INACTIVE
        Should Be Equal As Strings  ${resp.json()[1]['account']['status']}  INACTIVE
     

JD-TC-SuperadminGetAccount-151
	Comment  Get Account Data when   accntStatus-eq=INACTIVE  id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
    	${id} =   get_acc_id  ${PUSERNAME1}
        ${resp} =   Get Accounts    accntStatus-eq=INACTIVE  id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  0
        

JD-TC-SuperadminGetAccount-152
	Comment  Get Account Data when   accntStatus-eq=INACTIVE  businessName-eq=Anjali Health Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    accntStatus-eq=INACTIVE  businessName-eq=Anjali Health Care
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  0
       

JD-TC-SuperadminGetAccount-153
	Comment  Get Account Data when   accntStatus-eq=INACTIVE  serviceSector=health
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    accntStatus-eq=INACTIVE  serviceSector-eq=1
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      


JD-TC-SuperadminGetAccount-154
        Comment  Get Account Data when id-eq=${id}  accntStatus-eq=INACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME4}
        ${resp1} =  Delete Account  id-eq=${id}  accntStatus-eq=INACTIVE  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    id-eq=${id}   accntStatus-eq=INACTIVE
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  INACTIVE
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp} =    ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200


