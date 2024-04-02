*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
# Library           ExcelLibrary
Library           OperatingSystem
Library           robot.api.logger
Library           /ebs/TDD/Imageupload.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
*** Variables ***

${xlFile}      ${EXECDIR}/TDD/JitemSample.xlsx

*** Test Cases ***

JD-TC-CreateItemJrx-1

    [Documentation]  Create Item Jrx 

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${itemName}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    ${description}   getColumnValuesByName  ${sheet1}  ${colnames[1]}
    ${sku}   getColumnValuesByName  ${sheet1}  ${colnames[2]}
    ${hsnCode}   getColumnValuesByName  ${sheet1}  ${colnames[3]}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME269}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${resp}=    Upload Jrx item SA  ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200