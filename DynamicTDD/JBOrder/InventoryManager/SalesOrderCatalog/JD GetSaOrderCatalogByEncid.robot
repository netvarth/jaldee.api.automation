*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_


*** Test Cases ***

JD-TC-Get SalesOrder Catalog By Encid-1

    [Documentation]  create sales order catalog.(inventory manager is false) then get that catalog by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME37}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}




JD-TC-Get SalesOrder Catalog By Encid-2

    [Documentation]  update sales order catalog .(inventory manager is false) then get sales order catalog by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.first name
    Set Suite Variable  ${Name1}
    ${resp}=  Update SalesOrder Catalog    ${sa_catlog_id}  name=${Name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name1}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}



JD-TC-Get SalesOrder Catalog By Encid-3

    [Documentation]  Disable sales order catalog.(inventory manager is false).Then get salesorder catalog by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update SalesOrder Catalog Status   ${sa_catlog_id}     ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name1}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}


JD-TC-Get SalesOrder Catalog By Encid-4

    [Documentation]  create  sales order catalog where name as number.(inventory manager is false).then get sales order catalog by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${Name2}=    FakerLibrary.last name
    Set Suite Variable  ${Name2}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name2}  ${St_Id1}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id1}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False    ${store_id1}  ${invalidNum}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id1}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id1}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${invalidNum}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}





JD-TC-Get SalesOrder Catalog By Encid-5

    [Documentation]  create  sales order  catalog where name as invalid string.(inventory manager is false).then get catalog by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}  ${invalidstring}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id2}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id2}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${invalidstring}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}




JD-TC-Get SalesOrder Catalog By Encid-6

    [Documentation]  create sales order inventory catalog from main account then get catalog by encid  from user login(without admin privilege).(inventory manager is false)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name3}=    FakerLibrary.last name
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}  ${Name3}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${sa_catlog_id3}  ${resp.json()}


    # ${resp}=  Get Waitlist Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Enable Disable Department  ${toggle[0]}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END

    # ${dep_name1}=  FakerLibrary.bs
    # ${dep_code1}=   Random Int  min=100   max=999
    # ${dep_desc1}=   FakerLibrary.word   
    #     ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Test Variable  ${dep_id}  ${resp1.json()}



     
    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Test Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
 
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${loginId_n}=     Random Int  min=111111  max=999999

    ${resp}=    Reset LoginId  ${u_id1}  ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Password_n}=    Random Int  min=11111111  max=99999999
   
    ${resp}=    Forgot Password   loginId=${loginId_n}  password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U1}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${loginId_n}  ${Password_n}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id3}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name3}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}


JD-TC-Get SalesOrder Catalog By Encid-7

    [Documentation]  create  sales order catalog where name as invalid string.(inventory manager is true)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid}  ${resp.json()}
    ${inv_cat_encid1}=  Create List  ${inv_cat_encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id1}  ${Name}  ${boolean[1]}  ${inv_cat_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id4}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id4}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()['encId']}   ${sa_catlog_id4}
    Should Be Equal As Strings    ${resp.json()['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name}    
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryCatalog']['invCatEncIdList'][0]}    ${inv_cat_encid}



JD-TC-Get SalesOrder Catalog By Encid-UH1

    [Documentation]  Get SalesOrder Catalog By Encid  with invalid catalog id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog By Encid    ${store_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}
    

JD-TC-Get SalesOrder Catalog By Encid-UH2

    [Documentation]  Get SalesOrder Catalog By Encid without login.

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id4} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get SalesOrder Catalog By Encid-UH3

    [Documentation]  Get SalesOrder Catalog By Encid using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id4} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get SalesOrder Catalog By Encid-UH4

    [Documentation]  Get SalesOrder Catalog By Encid using another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog By Encid   ${sa_catlog_id4} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}






