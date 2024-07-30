*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Delete All Sessions
Force Tags        ITEM
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

${xlFile}       ${EXECDIR}/TDD/JitemSample.xlsx
${xlFile2}      ${EXECDIR}/TDD/JitemSample2.xlsx

*** Test Cases ***

JD-TC-CreateItemJrx-1

    [Documentation]  Create Item Jrx with xlFile

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${itemName}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    ${description}   getColumnValuesByName  ${sheet1}  ${colnames[1]}
    ${sku}   getColumnValuesByName  ${sheet1}  ${colnames[2]}
    ${hsnCode}   getColumnValuesByName  ${sheet1}  ${colnames[3]}
    Set Suite Variable      ${hsnCode}
    
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

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Imageupload.UploadJrxitemSA   ${cookie}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemJrx-UH1

    [Documentation]  Create Item Jrx with xl file - same xl file  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${hsn}=     Random Int  min=999  max=9999

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Imageupload.UploadJrxitemSA   ${cookie}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${NAME_ALREADY_EXIST}

JD-TC-CreateItemJrx-UH2

    [Documentation]  Create Item Jrx with xl file - random hsn code  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     Random Int  min=999  max=9999

    ${resp}=    Create Item Hsn SA  ${account_id}  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Hsn id

    ${resp}=    Imageupload.UploadJrxitemSA   ${cookie}   ${xlFile2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${INVALID_FIELD}