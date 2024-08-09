*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-Get_Lead_Product_Count_By_Filter-1

    [Documentation]   Get Lead Product Count By Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${typeName}=    FakerLibrary.Name
    Set Suite Variable      ${typeName}

    ${resp}=    Create Lead Product  ${typeName}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable      ${id1}  ${resp.json()['id']}

    ${typeName2}=    FakerLibrary.Name
    Set Suite Variable      ${typeName2}

    ${resp}=    Create Lead Product  ${typeName2}  ${productEnum[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid2}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable      ${id2}  ${resp.json()['id']}

    ${resp}=    Get Lead Product By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    ${length}=  Get Length  ${resp.json()}

    ${resp}=    Get Lead Product Count By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          ${length} 

JD-TC-Get_Lead_Product_Count_By_Filter-2

    [Documentation]   Get Lead Product Count By Filter - by id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  id-eq=${id2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          1
    
JD-TC-Get_Lead_Product_Count_By_Filter-3

    [Documentation]   Get Lead Product Count By Filter - by account

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  account-eq=${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          2

JD-TC-Get_Lead_Product_Count_By_Filter-4

    [Documentation]   Get Lead Product Count By Filter - by uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  uid-eq=${lpid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          1
    
JD-TC-Get_Lead_Product_Count_By_Filter-5

    [Documentation]   Get Lead Product Count By Filter - by typeName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  typeName-eq=${typeName}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          1

JD-TC-Get_Lead_Product_Count_By_Filter-6

    [Documentation]   Get Lead Product Count By Filter - by productEnum

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  productEnum-eq=${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          1

JD-TC-Get_Lead_Product_Count_By_Filter-7

    [Documentation]   Get Lead Product Count By Filter - by crmStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Product Count By Filter  crmStatus-eq=${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          2

JD-TC-Get_Lead_Product_Count_By_Filter-8

    [Documentation]   Get Lead Product Count By Filter - by createdDate

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${new_date}=  Evaluate  datetime.datetime.strptime('${DAY1}', '%Y-%m-%d').strftime('%d-%m-%Y')  datetime

    ${resp}=    Get Lead Product Count By Filter  createdDate-eq=${new_date}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          2

JD-TC-Get_Lead_Product_Count_By_Filter-UH1

    [Documentation]   Get Lead Product Count By Filter - without login

    ${resp}=    Get Lead Product Count By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

JD-TC-Get_Lead_Product_Count_By_Filter-UH2

    [Documentation]   Get Lead Product Count By Filter - provider dont have any product

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Get Lead Product Count By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          0

JD-TC-Get_Lead_Product_Count_By_Filter-UH3

    [Documentation]   Get Lead Product Count By Filter - where crm is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[1]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Get Lead Product Count By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}