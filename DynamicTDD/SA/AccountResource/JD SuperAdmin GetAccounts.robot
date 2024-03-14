*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Get Accounts
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variable ***
${tz}   Asia/Kolkata


*** Test Cases ***

JD-TC-SuperadminGetAccount-1
	[Documentation]  Get Account Data  when  id-eq=${id}  uid-eq=${uid}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${uid} =  get_uid  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
    
# *** Comments ***

JD-TC-SuperadminGetAccount-2
	[Documentation]  Get Account Data  when  id-eq=${id}  businessName-eq=${busName}
        
        ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
        Set Suite Variable  ${busName}  ${resp.json()['businessName']}

        ${resp}=   Get Accountsettings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Provider Logout 
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts  id-eq=${id}  businessName-eq=${busName}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${busName}
      

# *** Test Cases ***

JD-TC-SuperadminGetAccount-3
        [Documentation]  Get Account Data when id-eq=${id}   license-eq=${lic_id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id}  ${resp.json()['id']} 
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
         
        ${resp} =  Get Accounts    id-eq=${id}  license-eq=${lic_id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}
      


JD-TC-SuperadminGetAccount-4
        [Documentation]  Get Account Data when id-eq=${id}  serviceSector-eq=${domain_id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']} 

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id}  ${resp.json()['id']} 
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp} =  Get Accounts    id-eq=${id}  serviceSector-eq=${domain_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        
# *** Comments ***   

JD-TC-SuperadminGetAccount-5
        [Documentation]  Get Account Data when id-eq=${id}  serviceSubSector-eq=${subdomain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}

        ${resp} =  Get Accounts    id-eq=${id}  serviceSubSector-eq=${subdomain_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
       

JD-TC-SuperadminGetAccount-6
        [Documentation]  Get Account Data when id-eq=${id} accountLinkedPhoneNumber-eq=${PUSERNAME1} 
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
        [Documentation]  Get Account Data when id-eq=${id}  accntStatus-eq=ACTIVE
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
       [Documentation]  Get Account Data when id-eq=${id}  claimStatus-eq=Claimed
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
	[Documentation]  Get Account Data when id-eq=${id}  createdDate-eq=${currentDate}
        
        ${PH_Number}    Random Number 	digits=5  #fix_len=True
        ${ph}=  Evaluate   ${PUSERNAME}+${PH_Number}
        Log   ${ph}
        
        ${ph1}=  Evaluate  ${ph}+1000000000
        ${ph2}=  Evaluate  ${ph}+2000000000

        ${licresp}=   Get Licensable Packages
        Log   ${licresp.content}
        Should Be Equal As Strings  ${licresp.status_code}  200
        ${liclen}=  Get Length  ${licresp.json()}
        Set Test Variable  ${licpkgid}  ${licresp.json()[0]['pkgId']}
        Set Test Variable  ${licpkgname}  ${licresp.json()[0]['displayName']}

        # ${corp_resp}=   get_iscorp_subdomains  1

        ${resp}=  Get BusinessDomainsConf
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${dom_len}=  Get Length  ${resp.json()}
        # ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${dom}=  Random Int  min=0   max=${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        
        FOR  ${subindex}  IN RANGE  ${sdom_len}
        #     ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            ${sdom}=  Random Int  min=0   max=${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
        #     ${is_corp}=  check_is_corp  ${subdomain}
        #     Exit For Loop If  '${is_corp}' == 'False'
        END
        Log   ${subdomain}
        
        ${fname}=  FakerLibrary.name
        ${lname}=  FakerLibrary.lastname
        ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${ph}  ${licpkgid}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${ph}  0
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  03s
        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${accId}  ${resp.json()['id']}

        ${resp}=  Provider Logout
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${id} =  get_acc_id  ${ph}

        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate}

        ${resp} =  Get Accounts    id-eq=${id}  createdDate-eq=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
     



JD-TC-SuperadminGetAccount-10
        [Documentation]  Get Account Data when id-eq=${id}  verifiedLevel-eq=NONE
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
	[Documentation]  Get Account Data when id-eq=${id}  searchEnabled-eq=true
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
        [Documentation]  Get Account Data when businessName-eq=${bname}  license-eq=${lic_id}  id-eq=${id}  
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}

        # ${id} =  get_acc_id  ${PUSERNAME1}
        # ${licence} =  Get Licensable Packages  
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  

        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp} =  Get Accounts    businessName-eq=${bname}   license-eq=${lic_id}   id-eq=${id}   
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       


JD-TC-SuperadminGetAccount-13
        [Documentation]  Get Account Data when businessName-eq=${bname}  serviceSector-eq=${domain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=${bname}  serviceSector-eq=${domain_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1  
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
       

JD-TC-SuperadminGetAccount-14
        [Documentation]  Get Account Data when businessName-eq=${bname}   serviceSubSector-eq=${subdomain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=${bname}  serviceSubSector-eq=${subdomain_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
       

JD-TC-SuperadminGetAccount-15   
       [Documentation]  Get Account Data when businessName-eq=${bname}  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=${bname}   accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
    

JD-TC-SuperadminGetAccount-16
        [Documentation]  Get Account Data when businessName-eq=${bname}  accntStatus-eq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-eq=${bname}  accntStatus-eq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
       

JD-TC-SuperadminGetAccount-17
        [Documentation]  Get Account Data when businessName-eq=${bname}  claimStatus-eq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-eq=${bname}  claimStatus-eq=Claimed
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        

JD-TC-SuperadminGetAccount-18
        [Documentation]  Get Account Data when businessName-eq=${bname}  createdDate-eq=${currentDate}  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        # Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts    businessName-eq=${bname}  createdDate-eq=${currentDate}  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        

JD-TC-SuperadminGetAccount-19
        [Documentation]  Get Account Data when businessName-eq=${bname}  verifiedLevel-eq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-eq=${bname}  verifiedLevel-eq=NONE
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
       

JD-TC-SuperadminGetAccount-20
	[Documentation]  Get Account Data when businessName-eq=${bname}  searchEnabled-eq=true
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-eq=${bname}   searchEnabled-eq=true
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
       


JD-TC-SuperadminGetAccount-21
        [Documentation]  Get Account Data when license-eq=${lic_id}  serviceSector-eq=${domain_id}   id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        # Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}

        # ${id} =  get_acc_id  ${PUSERNAME1}

        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   license-eq=${lic_id}  serviceSector-eq=${domain_id}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}   ${lic_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
 	Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      



JD-TC-SuperadminGetAccount-22
        [Documentation]  Get Account Data when license-eq=${lic_id}  serviceSubSector-eq=${subdomain_id}  id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}
        
        
        # ${id} =  get_acc_id  ${PUSERNAME1}
        # ${licence} =  Get Licensable Packages
        # Set Test Variable  ${lic_id}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts    license-eq=${lic_id}  serviceSubSector-eq=${subdomain_id}  id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     
         

JD-TC-SuperadminGetAccount-23  
       [Documentation]  Get Account Data when license-eq=${lic_id}   accountLinkedPhoneNumber-eq=${PUSERNAME1} 
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        # ${resp}=  Get Business Profile
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${id}  ${resp.json()['id']}
        # Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        # Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}
        
        
        # ${id} =  get_acc_id  ${PUSERNAME1}
        # ${licence} =  Get Licensable Packages
        # Set Test Variable  ${lic_id}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts    license-eq=${lic_id}    accountLinkedPhoneNumber-eq=${PUSERNAME1} 
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
     



JD-TC-SuperadminGetAccount-24
        [Documentation]  Get Account Data when license-eq=${lic_id}  accntStatus-eq=ACTIVE  id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts   license-eq=${lic_id}  accntStatus-eq=ACTIVE   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}   ${lic_id} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
 



JD-TC-SuperadminGetAccount-25
        [Documentation]  Get Account Data when license-eq=${lic_id}  claimStatus-eq=Claimed   id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts  license-eq=${lic_id}  claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     


JD-TC-SuperadminGetAccount-26
        [Documentation]  Get Account Data when license-eq=${lic_id}  createdDate-eq=${currentDate}   id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   license-eq=${lic_id}  createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      



JD-TC-SuperadminGetAccount-27
        [Documentation]  Get Account Data when license-eq=${lic_id}   verifiedLevel-eq=NONE   id-eq=${id} 
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts  license-eq=${lic_id}  verifiedLevel-eq=NONE    id-eq=${id} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}   NONE  
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
       
        
JD-TC-SuperadminGetAccount-28
	[Documentation]  Get Account Data when license-eq=${lic_id}   searchEnabled-eq=true  id-eq=${id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts  license-eq=${lic_id}   searchEnabled-eq=true    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
   

JD-TC-SuperadminGetAccount-29
        [Documentation]  Get Account Data when serviceSector-eq=${domain_id}  serviceSubSector-eq=${subdomain_id}   id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-eq=${domain_id}  serviceSubSector-eq=${subdomain_id}    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-30 
       [Documentation]  Get Account Data when serviceSector-eq=${domain_id}  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-eq=${domain_id}  accountLinkedPhoneNumber-eq=${PUSERNAME1}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-31
        [Documentation]  Get Account Data when serviceSector-eq=${domain_id}  accntStatus-eq=ACTIVE   id-eq=${id}
        
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=${domain_id}   accntStatus-eq=ACTIVE   id-eq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}   ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
         

JD-TC-SuperadminGetAccount-32
        [Documentation]  Get Account Data when serviceSector-eq=${domain_id}  claimStatus-eq=Claimed   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=${domain_id}    claimStatus-eq=Claimed   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
       

JD-TC-SuperadminGetAccount-33
        [Documentation]  Get Account Data when serviceSector-eq=${domain_id}  createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSector-eq=${domain_id}   createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-34
        [Documentation]  Get Account Data when  serviceSector-eq=${domain_id}  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=${domain_id}  verifiedLevel-eq=NONE   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      
        
JD-TC-SuperadminGetAccount-35
	[Documentation]  Get Account Data when serviceSector-eq=${domain_id}  searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSector-eq=${domain_id}   searchEnabled-eq=true   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-36
        [Documentation]  Get Account Data when serviceSubSector-eq=${subdomain_id}  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        Set Suite Variable  ${domain_id}  ${resp.json()['serviceSector']['id']}
        Set Suite Variable  ${subdomain_id}  ${resp.json()['serviceSubSector']['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSubSector-eq=${subdomain_id}  accountLinkedPhoneNumber-eq=${PUSERNAME1}    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1} 
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}


JD-TC-SuperadminGetAccount-37
        [Documentation]  Get Account Data when serviceSubSector-eq=${subdomain_id}   accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=${subdomain_id}  accntStatus-eq=ACTIVE  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       


JD-TC-SuperadminGetAccount-38 
        [Documentation]  Get Account Data when serviceSubSector-eq=${subdomain_id}  claimStatus-eq=Claimed  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=${subdomain_id}  claimStatus-eq=Claimed    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     

JD-TC-SuperadminGetAccount-39
        [Documentation]  Get Account Data when serviceSubSector-eq=${subdomain_id}  createdDate-eq=${currentDate}  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSubSector-eq=${subdomain_id}  createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       

JD-TC-SuperadminGetAccount-40
        [Documentation]  Get Account Data when  serviceSubSector-eq=${subdomain_id}  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-eq=${subdomain_id}  verifiedLevel-eq=NONE    id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
      
        
JD-TC-SuperadminGetAccount-41
	[Documentation]  Get Account Data when serviceSubSector-eq=${subdomain_id}  searchEnabled-eq=true  id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSubSector-eq=${subdomain_id}   searchEnabled-eq=true  id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  True
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
       

JD-TC-SuperadminGetAccount-42
	[Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   accntStatus-eq=ACTIVE   id-eq=${id}
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
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   claimStatus-eq=Claimed  id-eq=${id}
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
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}    createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1}   createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
  

JD-TC-SuperadminGetAccount-45
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   verifiedLevel-eq=NONE  id-eq=${id} 
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
	[Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}   searchEnabled-eq=true   id-eq=${id} 
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
        [Documentation]  Get Account Data when  accntStatus-eq=ACTIVE  claimStatus-eq=Claimed   id-eq=${id}
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
        [Documentation]  Get Account Data when  accntStatus-eq=ACTIVE   createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accntStatus-eq=ACTIVE  createdDate-eq=${currentDate}   id-eq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}   1
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}   ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
  

JD-TC-SuperadminGetAccount-49
        [Documentation]  Get Account Data when  accntStatus-eq=ACTIVE   verifiedLevel-eq=NONE   id-eq=${id}
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
	[Documentation]  Get Account Data when  accntStatus-eq=ACTIVE  searchEnabled-eq=true   id-eq=${id}
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
        [Documentation]  Get Account Data when  claimStatus-eq=Claimed   createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   claimStatus-eq=Claimed   createdDate-eq=${currentDate}   id-eq=${id}
   	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}   Claimed 
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}


JD-TC-SuperadminGetAccount-52
        [Documentation]  Get Account Data when   claimStatus-eq=Claimed   verifiedLevel-eq=NONE   id-eq=${id}
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
	[Documentation]  Get Account Data when  claimStatus-eq=Claimed  searchEnabled-eq=true  id-eq=${id}
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
	[Documentation]  Get Account Data when createdDate-eq=${currentDate}  accntStatus-eq=ACTIVE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate}  
        ${resp} =  Get Accounts    createdDate-eq=${currentDate}  accntStatus-eq=ACTIVE   id-eq=${id}
	${count} =  Get Length  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id} 
     

JD-TC-SuperadminGetAccount-55
	[Documentation]  Get Account Data when createdDate-eq=${currentDate}  verifiedLevel-eq=NONE   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate}
        ${resp} =  Get Accounts    createdDate-eq=${currentDate}  verifiedLevel-eq=NONE   id-eq=${id}
    	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
       

JD-TC-SuperadminGetAccount-56
	[Documentation]  Get Account Data when createdDate-eq=${currentDate}  searchEnabled-eq=true   id-eq=${id}
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
	[Documentation]  Get Account Data when  verifiedLevel-eq=NONE  searchEnabled-eq=true   id-eq=${id}
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
        [Documentation]  Get Account Data when businessName-eq=${bname}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        Set Suite Variable  ${bname}  ${resp.json()['businessName']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp} =  Get Accounts  businessName-eq=${bname}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =   Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['businessName']}  ${bname}
     

JD-TC-SuperadminGetAccount-59
	[Documentation]  Get Account Data when createdDate-eq=${currentDate}   id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =  Get Accounts  createdDate-eq=${currentDate}   id-eq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['createdDate']}  ${currentDate}
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
     

JD-TC-SuperadminGetAccount-60
	[Documentation]  Get Account Data when id-eq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id} 
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['id']}  ${id}
      

JD-TC-SuperadminGetAccount-61
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-eq=${PUSERNAME1}  
        ${resp}=  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp}=  Get Accounts  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
 	Should Be Equal As Strings  ${resp.status_code}  200 
	${count}=  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  1
        Should Be Equal As Strings  ${resp.json()[0]['account']['accountLinkedPhNo']}  ${PUSERNAME1}  
        

JD-TC-SuperadminGetAccount-62
	[Documentation]  Get Account Data when  uid-eq=${uid}
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
	[Documentation]  Get Account Data when accntStatus-eq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   accntStatus-eq=ACTIVE
        Should Be Equal As Strings  ${resp.status_code}  200 
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-64
	[Documentation]  Get Account Data when  serviceSubSector-eq=${subdomain_id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    serviceSubSector-eq=${subdomain_id} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSubSector']['id']}  ${subdomain_id}
       

JD-TC-SuperadminGetAccount-65
	[Documentation]  Get Account Data when serviceSector-eq=${domain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   serviceSector-eq=${domain_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['serviceSector']['id']}  ${domain_id}
        

JD-TC-SuperadminGetAccount-66
	[Documentation]  Get Account Data when  license-eq=${lic_id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts   license-eq=${lic_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['licensePkgID']}  ${lic_id}
        

JD-TC-SuperadminGetAccount-67
	[Documentation]  Get Account Data when   claimStatus-eq=Claimed 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   claimStatus-eq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['claimStatus']}  Claimed
        

JD-TC-SuperadminGetAccount-68
	[Documentation]  Get Account Data when  verifiedLevel-eq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  verifiedLevel-eq=NONE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['verifyLevel']}  NONE
        

JD-TC-SuperadminGetAccount-69
	[Documentation]  Get Account Data when    searchEnabled-eq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    searchEnabled-eq=false
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        Should Be Equal As Strings  ${resp.json()[0]['account']['enableSearch']}  False
        

JD-TC-SuperadminGetAccount-70
	[Documentation]  Get Account Data  when  id-neq=${id}  uid-neq=${uid}
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
	[Documentation]  Get Account Data  when  id-neq=${id}  businessName-neq=${bname}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  id-neq=${id}  businessName-neq=${bname}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-72
        [Documentation]  Get Account Data when id-neq=${id}   license-neq=${lic_id} 
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  license-neq=${lic_id} 
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-73
        [Documentation]  Get Account Data when id-neq=${id}  serviceSector-neq=${domain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  serviceSector-neq=${domain_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-74
        [Documentation]  Get Account Data when id-neq=${id}  serviceSubSector-neq=${subdomain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  serviceSubSector-neq=${subdomain_id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-75
        [Documentation]  Get Account Data when id-neq=${id} accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-eq=${id}  accountLinkedPhoneNumber-eq=${PUSERNAME1} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-76
        [Documentation]  Get Account Data when id-neq=${id}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}   accntStatus-neq=ACTIVE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       
  

JD-TC-SuperadminGetAccount-77
       [Documentation]  Get Account Data when id-neq=${id}  claimStatus-neq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  claimStatus-eq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-78
	[Documentation]  Get Account Data when id-neq=${id}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate} =  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =  Get Accounts    id-neq=${id}  createdDate-neq=${currentDate}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-79
        [Documentation]  Get Account Data when id-neq=${id}  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-eq=${id}  verifiedLevel-eq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
    


JD-TC-SuperadminGetAccount-80
	[Documentation]  Get Account Data when id-neq=${id}  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id}  searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
      


JD-TC-SuperadminGetAccount-81
        [Documentation]  Get Account Data when businessName-neq=${bname}  license-neq=${lic_id}   id-neq=${id}  
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts   businessName-neq=${bname}  license-neq=${lic_id}     id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200 
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-82
        [Documentation]  Get Account Data when businessName-neq=${bname}  serviceSector-neq=${domain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-neq=${bname}  serviceSector-neq=${domain_id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-83
        [Documentation]  Get Account Data when businessName-neq=${bname}   serviceSubSector-neq=${subdomain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=${bname}  serviceSubSector-neq=${subdomain_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-84   
       [Documentation]  Get Account Data when businessName-neq=${bname}  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=${bname}  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
  	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
        

JD-TC-SuperadminGetAccount-85
        [Documentation]  Get Account Data when businessName-neq=${bname}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    businessName-neq=${bname}  accntStatus-neq=ACTIVE
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
    

JD-TC-SuperadminGetAccount-86
        [Documentation]  Get Account Data when businessName-neq=${bname}  claimStatus-neq=Claimed
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-neq=${bname}  claimStatus-neq=Claimed
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-87
        [Documentation]  Get Account Data when businessName-neq=${bname}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts    businessName-neq=${bname}  createdDate-neq=${currentDate}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     


JD-TC-SuperadminGetAccount-88
        [Documentation]  Get Account Data when businessName-neq=${bname}  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    businessName-neq=${bname}  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-89
	[Documentation]  Get Account Data when businessName-neq=${bname}  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   businessName-neq=${bname}   searchEnabled-neq=false
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-90
        [Documentation]  Get Account Data when license-neq=${lic_id}   serviceSector-neq=${domain_id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts   license-neq=${lic_id}  serviceSector-neq=${domain_id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-91
        [Documentation]  Get Account Data when license-neq=${lic_id}  serviceSubSector-neq=${subdomain_id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts    license-neq=${lic_id}  serviceSubSector-neq=${subdomain_id}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-92
       [Documentation]  Get Account Data when license-neq=${lic_id}  accountLinkedPhoneNumber-neq=${PUSERNAME1} 
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts    license-neq=${lic_id}   accountLinkedPhoneNumber-neq=${PUSERNAME1}
  	Should Be Equal As Strings  ${resp.status_code}  200 
        ${count} =  Get Length  ${resp.json()}
        ${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-93
        [Documentation]  Get Account Data when license-neq=${lic_id}  accntStatus-neq=ACTIVE   id-neq=${id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts   license-neq=${lic_id}   accntStatus-neq=ACTIVE    id-neq=${id}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-94
        [Documentation]  Get Account Data when license-neq=${lic_id}  claimStatus-neq=Claimed   id-eq=${id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts  license-neq=${lic_id}  claimStatus-neq=Claimed
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-95
        [Documentation]  Get Account Data when license-neq=${lic_id}  createdDate-neq=${currentDate}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   license-neq=${lic_id}  createdDate-neq=${currentDate}
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-96
        [Documentation]  Get Account Data when license-neq=${lic_id}   verifiedLevel-neq=NONE   id-eq=${id} 
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts  license-neq=${lic_id}  verifiedLevel-neq=NONE   id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-97
	[Documentation]  Get Account Data when license-neq=${lic_id}  searchEnabled-neq=false   id-neq=${id}
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp} =  Get Accounts  license-neq=${lic_id}  searchEnabled-neq=false   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
 

JD-TC-SuperadminGetAccount-98
        [Documentation]  Get Account Data when serviceSector-neq=${domain_id}  serviceSubSector-neq=${subdomain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-neq=${domain_id}  serviceSubSector-neq=${subdomain_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-99
       [Documentation]  Get Account Data when serviceSector-neq=${domain_id}  accountLinkedPhoneNumber-neq=${PUSERNAME1}    id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSector-neq=${domain_id}  accountLinkedPhoneNumber-neq=${PUSERNAME1}   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-100
        [Documentation]  Get Account Data when serviceSector-neq=${domain_id}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-eq=${domain_id}   accntStatus-eq=ACTIVE
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   

JD-TC-SuperadminGetAccount-101
        [Documentation]  Get Account Data when serviceSector-neq=${domain_id}  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-neq=${domain_id}    claimStatus-neq=Claimed
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   

JD-TC-SuperadminGetAccount-102
        [Documentation]  Get Account Data when serviceSector-neq=${domain_id}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSector-neq=${domain_id}  createdDate-neq=${currentDate}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
	

JD-TC-SuperadminGetAccount-103
        [Documentation]  Get Account Data when  serviceSector-neq=${domain_id}  verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSector-neq=${domain_id}  verifiedLevel-neq=NONE    id-neq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
  
        
JD-TC-SuperadminGetAccount-104
	[Documentation]  Get Account Data when serviceSector-neq=${domain_id}  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSector-neq=${domain_id}   searchEnabled-neq=false
        Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     
     
JD-TC-SuperadminGetAccount-105
        [Documentation]  Get Account Data when serviceSubSector-neq=${subdomain_id}  accountLinkedPhoneNumber-neq=${PUSERNAME1}    id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    serviceSubSector-neq=${subdomain_id}  accountLinkedPhoneNumber-neq=${PUSERNAME1}   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
        ${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-106
        [Documentation]  Get Account Data when serviceSubSector-neq=${subdomain_id} accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=${subdomain_id}  accntStatus-neq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-107
        [Documentation]  Get Account Data when serviceSubSector-neq=${subdomain_id}  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=${subdomain_id}  claimStatus-neq=Claimed   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True
    

JD-TC-SuperadminGetAccount-108
        [Documentation]  Get Account Data when serviceSubSector-neq=${subdomain_id}  createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  serviceSubSector-neq=${subdomain_id}  createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   
     

JD-TC-SuperadminGetAccount-109
        [Documentation]  Get Account Data when  serviceSubSector-neq=${subdomain_id}  verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   serviceSubSector-neq=${subdomain_id}  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
   
        
JD-TC-SuperadminGetAccount-110
	[Documentation]  Get Account Data when serviceSubSector-neq=${subdomain_id}  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  serviceSubSector-neq=${subdomain_id}   searchEnabled-neq=false   id-neq=${id}
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-111
	[Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   accntStatus-neq=ACTIVE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}  accntStatus-neq=ACTIVE  id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-112
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   claimStatus-neq=Claimed  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   claimStatus-neq=Claimed   id-neq=${id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
 
JD-TC-SuperadminGetAccount-113
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}    createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
  

JD-TC-SuperadminGetAccount-114
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}    verifiedLevel-neq=NONE  id-neq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   verifiedLevel-neq=NONE   id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     
        
JD-TC-SuperadminGetAccount-115
	[Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}   searchEnabled-neq=false   id-neq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}   searchEnabled-neq=false   id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-116
        [Documentation]  Get Account Data when  accntStatus-neq=ACTIVE  claimStatus-neq=Claimed   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  claimStatus-neq=Claimed
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
     

JD-TC-SuperadminGetAccount-117
        [Documentation]  Get Account Data when  accntStatus-neq=ACTIVE   createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts  accntStatus-neq=ACTIVE  createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-118
        [Documentation]  Get Account Data when  accntStatus-neq=ACTIVE   verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  verifiedLevel-neq=NONE  id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-119
	[Documentation]  Get Account Data when  accntStatus-neq=ACTIVE  searchEnabled-neq=false   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE  searchEnabled-neq=false   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-120
        [Documentation]  Get Account Data when  claimStatus-neq=Claimed   createdDate-neq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${currentdate}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${currentDate}  ${currentdate} 
        ${resp} =   Get Accounts   claimStatus-neq=Claimed   createdDate-neq=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-121
        [Documentation]  Get Account Data when   claimStatus-neq=Claimed   verifiedLevel-neq=NONE   id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-neq=Claimed   verifiedLevel-neq=NONE   id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
        
JD-TC-SuperadminGetAccount-122
	[Documentation]  Get Account Data when  claimStatus-neq=Claimed  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   claimStatus-neq=Claimed  searchEnabled-neq=false    id-neq=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       
        
JD-TC-SuperadminGetAccount-123
	[Documentation]  Get Account Data when createdDate-neq=${currentDate}  accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}  accntStatus-neq=ACTIVE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}   True 
       

JD-TC-SuperadminGetAccount-124
	[Documentation]  Get Account Data when createdDate-neq=${currentDate}  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1} 
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}  verifiedLevel-neq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-125
	[Documentation]  Get Account Data when createdDate-neq=${currentDate}  searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    createdDate-neq=${currentDate}   searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-126
	[Documentation]  Get Account Data when  verifiedLevel-neq=NONE  searchEnabled-neq=false  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   verifiedLevel-neq=NONE  searchEnabled-neq=false
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-127
	[Documentation]  Get Account Data when  uid-neq=${uid}
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
	[Documentation]  Get Account Data when  id-neq=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts    id-neq=${id} 
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-129
        [Documentation]  Get Account Data when businessName-neq=${bname}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  businessName-neq=${bname}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =   Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
    


JD-TC-SuperadminGetAccount-130
	[Documentation]  Get Account Data when  license-neq=${lic_id} 
        ${resp} =  Encrypted Provider Login   ${PUSERNAME1}   ${PASSWORD}
        Should Be Equal As Strings   ${resp.status_code}  200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${id}  ${resp.json()['id']}
        
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200   
        ${resp} =  Get Accounts   license-neq=${lic_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-131
        [Documentation]  Get Account Data when serviceSector-neq=${domain_id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   serviceSector-neq=${domain_id}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-132
	[Documentation]  Get Account Data when  serviceSubSector-neq=${subdomain_id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    serviceSubSector-neq=${subdomain_id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        

JD-TC-SuperadminGetAccount-133
        [Documentation]  Get Account Data when accountLinkedPhoneNumber-neq=${PUSERNAME1}  
        ${resp}=  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp}=  Get Accounts  accountLinkedPhoneNumber-neq=${PUSERNAME1}  
	Should Be Equal As Strings  ${resp.status_code}  200
	${count}=  Get Length  ${resp.json()}  
        ${status} =  Evaluate  ${count}>=0 
        Should Be Equal As Strings  ${status}  True 
       
JD-TC-SuperadminGetAccount-134
	[Documentation]  Get Account Data when accntStatus-neq=ACTIVE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   accntStatus-neq=ACTIVE
  	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True
       
JD-TC-SuperadminGetAccount-135
	[Documentation]  Get Account Data when   claimStatus-neq=Claimed 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   claimStatus-neq=Claimed
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-136
	[Documentation]  Get Account Data when createdDate-eq=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts  createdDate-neq=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      
        
JD-TC-SuperadminGetAccount-137
	[Documentation]  Get Account Data when  verifiedLevel-neq=NONE
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  verifiedLevel-eq=NONE
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
        


JD-TC-SuperadminGetAccount-138
	[Documentation]  Get Account Data when    searchEnabled-neq=false
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    searchEnabled-neq=false
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       


JD-TC-SuperadminGetAccount-139
        [Documentation]  Get Account Data when businessName-like=Anjali
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Anjali
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-140
        [Documentation]  Get Account Data when businessName-like=Health
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Health
 	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      

JD-TC-SuperadminGetAccount-141
        [Documentation]  Get Account Data when businessName-like=Care
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts  businessName-like=Care
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
       

JD-TC-SuperadminGetAccount-142
        [Documentation]  Get Account Data when id-gt=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
	${resp} =  Get Accounts   id-gt=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-143
        [Documentation]  Get Account Data when id-lt=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-lt=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-144
        [Documentation]  Get Account Data when id-le=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-le=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	
JD-TC-SuperadminGetAccount-145
        [Documentation]  Get Account Data when id-ge=${id}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
	${id} =  get_acc_id  ${PUSERNAME1}
        ${resp} =  Get Accounts   id-ge=${id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 


JD-TC-SuperadminGetAccount-146
        [Documentation]  Get Account Data when createdDate-gt=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-gt=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${len} =  Get Length  ${resp.json()}
        Should Be Equal As Integers  ${len}  0
	

JD-TC-SuperadminGetAccount-147
        [Documentation]  Get Account Data when createdDate-lt=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-lt=${currentDate}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	

JD-TC-SuperadminGetAccount-148
        [Documentation]  Get Account Data when createdDate-ge=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-ge=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	
JD-TC-SuperadminGetAccount-149
        [Documentation]  Get Account Data when  createdDate-le=${currentDate}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts   createdDate-le=${currentDate}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
	


JD-TC-SuperadminGetAccount-150
	[Documentation]  Get Account Data when  accountstatus=INACTIVE
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
	[Documentation]  Get Account Data when   accntStatus-eq=INACTIVE  id-eq=${id} 
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
    	${id} =   get_acc_id  ${PUSERNAME1}
        ${resp} =   Get Accounts    accntStatus-eq=INACTIVE  id-eq=${id} 
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  0
        

JD-TC-SuperadminGetAccount-152
	[Documentation]  Get Account Data when   accntStatus-eq=INACTIVE  businessName-eq=${bname}
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    accntStatus-eq=INACTIVE  businessName-eq=${bname}
        Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	Should Be Equal As Integers  ${count}  0
       

JD-TC-SuperadminGetAccount-153
	[Documentation]  Get Account Data when   accntStatus-eq=INACTIVE  serviceSector=health
        ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp} =  Get Accounts    accntStatus-eq=INACTIVE  serviceSector-eq=${domain_id}
	Should Be Equal As Strings  ${resp.status_code}  200
	${count} =  Get Length  ${resp.json()}
	${status} =  Evaluate  ${count}>=0 
	Should Be Equal As Strings  ${status}  True 
      


JD-TC-SuperadminGetAccount-154
        [Documentation]  Get Account Data when id-eq=${id}  accntStatus-eq=INACTIVE
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
        ${resp} =    Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200


