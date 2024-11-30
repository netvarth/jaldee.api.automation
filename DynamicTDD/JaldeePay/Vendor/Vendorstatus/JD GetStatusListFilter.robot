*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***


JD-TC-Get StatuList Filter-1

    [Documentation]  Get Vendorstatus With Filter with name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Populate Url For Vendor   ${account_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${loc_id1}=   Create Sample Location
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY} 

    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite Variable    ${DAY2} 

    ${name}=   FakerLibrary.word
    Set Suite Variable    ${name} 
    ${resp}=  CreateVendorStatus  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${encId}   ${resp.json()}


    ${resp}=   Get Vendorstatus With Filter   name-eq=${name}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}   ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}        ${toggle[0]}




JD-TC-Get StatuList Filter-2

    [Documentation]  Get Vendorstatus With Filter with createdDate

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Get Vendorstatus With Filter   createdDate-ge=${CUR_DAY}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}       ${toggle[0]}

JD-TC-Get StatuList Filter-3

    [Documentation]  Get Vendorstatus With Filter with status

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Get Vendorstatus With Filter   isEnabled-eq=${toggle[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}       ${toggle[0]}

JD-TC-Get StatuList Filter-4

    [Documentation]  Get Vendorstatus With Filter with encId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Get Vendorstatus With Filter   encId-eq=${encId}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}        ${toggle[0]}

JD-TC-Get StatuList Filter-5

    [Documentation]  Get Vendorstatus With Filter with all fileds

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Get Vendorstatus With Filter   encId-eq=${encId}   isEnabled-eq=${toggle[0]}    createdDate-ge=${CUR_DAY}  name-eq=${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}       ${toggle[0]}

JD-TC-Get StatuList Filter-6

    [Documentation]  Get Vendorstatus With Filter with status

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Vendorstatus With Filter   isEnabled-eq=${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []


JD-TC-Get StatuList Filter-UH1

    [Documentation]  Get Vendorstatus With Filter without login

    ${resp}=   Get Vendorstatus With Filter   encId-eq=${encId}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}



JD-TC-Get StatuList Filter-UH2

    [Documentation]  Get Vendorstatus With Filter where encId as wrong.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
     ${fake}=    Random Int  min=1000000   max=9999999   
    ${resp}=   Get Vendorstatus With Filter   encId-eq=${fake}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get StatuList Filter-UH3
    [Documentation]   Get Vendorstatus With Filter where created date is wrong.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
     ${fake}=    Random Int  min=1000000   max=9999999   
    ${resp}=   Get Vendorstatus With Filter   createdDate-ge=${DAY2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get StatuList Filter-UH4

    [Documentation]   Get Vendorstatus With Filter where name  is wrong.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${name}=   FakerLibrary.word
    ${resp}=  Get Vendorstatus With Filter   name-eq=${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []




