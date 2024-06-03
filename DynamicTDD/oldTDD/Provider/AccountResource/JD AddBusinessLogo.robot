*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Business Logo
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg

${order}    0
${fileSize}  0.00458


*** Test Cases ***

JD-TC-Add_Business_Logo-1
                                  
    [Documentation]               Add Business Logo
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${FileAction[0]}


JD-TC-Add_Business_Logo-UH1
                                  
    [Documentation]               Add Business Logo with invalid Provider id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invpid}=    Generate Random String  5  [NUMBERS]

    ${resp}=    Add Business Logo    ${invpid}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    4220


JD-TC-Add_Business_Logo-UH2
                                  
    [Documentation]               Add Business Logo with empty file name
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${empty}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Add_Business_Logo-UH3
                                  
    [Documentation]  Add Business Logo with empty file size
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${empty}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_SIZE_ERROR}


JD-TC-Add_Business_Logo-UH4
                                  
    [Documentation]               Add Business Logo with empty Action
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${empty}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    500


JD-TC-Add_Business_Logo-UH5
                                  
    [Documentation]               Add Business Logo with loan Action as remove
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[2]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Add_Business_Logo-UH6
                                  
    [Documentation]               Add Business Logo with empty caption
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${empty}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Add_Business_Logo-UH7
                                  
    [Documentation]               Add Business Logo with empty file type
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${empty}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Add_Business_Logo-UH8
                                  
    [Documentation]               Add Business Logo with empty order
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200