*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Invoice
Library           Collections
Library           String
Library           json
Library           FakerLibrary  
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Keywords ***

Licence Billing Detail
    Check And Create YNW Session
    ${resp}=   GET On Session   ynw   /provider/license/billing  expected_status=any
    [Return]  ${resp}
    

***Variables***
${tz}   Asia/Kolkata

***Test Cases***

JD-SA-TC-EnableDisableInvoiceGeneration-1
    
    [Documentation]   Superadmin Acceptpayment  in fullpaidamount

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Licensable Packages
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Licence Billing Detail
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get upgradable license
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
    # Set Test Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
    # ${resp}=  Change License Package  ${pkgid}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Active License
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Licence Billing Detail
	Log  ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Subscription
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # change_system_date  366

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Invoice Generartion   ${account_id1}    ${bool[0]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Config  
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices superadmin  ${account_id1}  ${paymentStatus[0]}
	Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date  366

    ${Day}=  db.get_date_by_timezone  ${tz}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoices superadmin  ${account_id1}  ${paymentStatus[0]}
	Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




