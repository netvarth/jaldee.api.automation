*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Department
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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg

${order}    0
${fileSize}  0.00458

*** Test Cases ***


JD-TC-Get_Department_Icon-1

    [Documentation]   Get Department Icon

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
      
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable     ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable     ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable     ${dep_desc1}
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        Set Suite Variable  ${dep_name1}  ${resp.json()['departments'][0]['departmentName']}
        Set Suite Variable  ${dep_code1}  ${resp.json()['departments'][0]['departmentCode']}
        Set Suite Variable  ${dep_desc1}  ${resp.json()['departments'][0]['departmentDescription']}
    END

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}=    Add Department Icon    ${dep_id}    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Department Icon    ${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['departmentName']}                   ${dep_name1}
    Should Be Equal As Strings    ${resp.json()['departmentId']}                     ${dep_id}
    Should Be Equal As Strings    ${resp.json()['departmentCode']}                   ${dep_code1}
    Should Be Equal As Strings    ${resp.json()['departmentDescription']}            ${dep_desc1}
    Should Be Equal As Strings    ${resp.json()['departmentStatus']}                 ${status[0]}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['action']}      ${LoanAction[0]}


JD-TC-Get_Department_Icon-UH1
                                  
    [Documentation]               Get Department Icon Where Department Icon is Removed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Department Icon    ${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['departmentName']}                   ${dep_name1}
    Should Be Equal As Strings    ${resp.json()['departmentId']}                     ${dep_id}
    Should Be Equal As Strings    ${resp.json()['departmentCode']}                   ${dep_code1}
    Should Be Equal As Strings    ${resp.json()['departmentDescription']}            ${dep_desc1}
    Should Be Equal As Strings    ${resp.json()['departmentStatus']}                 ${status[0]}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()['departmentLogo'][0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Department Icon    ${dep_id}    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Department Icon    ${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Get_Department_Icon-UH2
                                  
    [Documentation]               Get Department Icon With Another account
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Department Icon    ${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}


JD-TC-Get_Business_Logo-UH3
                                  
    [Documentation]               Get Business Logo without login

    ${resp}=    Get Department Icon    ${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}             419
    Should Be Equal As Strings    ${resp.json()}      ${SESSION_EXPIRED}
