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
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_




*** Test Cases ***

JD-TC-Get Inventory catalog Filter-1

    [Documentation]  create inventory catalog then Get Inventory catalog Filter.

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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME48}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}    ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}


    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}


    ${resp}=  Get Inventory catalog Filter    storeEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['catalogName']}    ${Name}

#    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${id}
    Should Be Equal As Strings    ${resp.json()[0]['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    # Should Be Equal As Strings    ${resp.json()[0]['storeName']}    ${Name}



JD-TC-Get Inventory catalog Filter-2

    [Documentation]  update inventory catalog then Get Inventory catalog Filter using accountid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.lastname
    Set Suite Variable  ${Name1}  
    ${resp}=  Update Inventory Catalog   ${Name1}  ${store_id}   ${encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventory catalog Filter    accountId-eq=${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['catalogName']}    ${Name1}

#    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${id}
    Should Be Equal As Strings    ${resp.json()[0]['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    # Should Be Equal As Strings    ${resp.json()[0]['storeName']}    ${Name}

JD-TC-Get Inventory catalog Filter-3

    [Documentation]  Update Inventory Catalog status as inactive then Get Inventory catalog Filter using catalogName
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Inventory Catalog status   ${encid}  ${InventoryCatalogStatus[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${resp}=  Get Inventory catalog Filter   catalogName-eq=${Name1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['catalogName']}    ${Name1}

#    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${id}
    Should Be Equal As Strings    ${resp.json()[0]['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    # Should Be Equal As Strings    ${resp.json()[0]['storeName']}    ${Name}

JD-TC-Get Inventory catalog Filter-4

    [Documentation]  create  inventory catalog from main account then get inventory catalog using encid from user login.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.last name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}


     
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
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Inventory catalog Filter   location-eq=${Name1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Inventory catalog Filter-5

    [Documentation]  create  inventory catalog where name as invalid string then Get Inventory catalog Filter using encid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Inventory Catalog   ${invalidstring}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventory catalog Filter   encId-eq=${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Inventory catalog Filter-6

    [Documentation]   update inventory catalog then Update Inventory Catalog status as disable and get with filter.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${encid}  ${resp.json()}

    ${resp}=  Update Inventory Catalog status   ${encid}  ${InventoryCatalogStatus[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${resp}=  Get Inventory catalog Filter   status-eq=${InventoryCatalogStatus[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${InventoryCatalogStatus[1]}


JD-TC-Get Inventory catalog Filter-UH1

    [Documentation]    Get Inventory catalog Filter with invalid encid id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Get Inventory catalog Filter   encId-eq=${Name}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []
    


JD-TC-Get Inventory catalog Filter-UH2

    [Documentation]  Get Inventory catalog Filter without login.

    ${resp}=  Get Inventory catalog Filter   encId-eq=${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Inventory catalog Filter-UH3

    [Documentation]  Get Inventory catalog Filter using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Inventory catalog Filter   encId-eq=${encid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}



    



