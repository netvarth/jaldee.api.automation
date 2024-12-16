*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Business Logo
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
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg

${order}    0
${fileSize}  0.00458


*** Test Cases ***

JD-TC-Get_Business_Logo-1
                                  
    [Documentation]               Get Business Logo
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
      
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    generate_filename
    Set Suite variable    ${fileName}

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
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
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}


JD-TC-Get_Business_Logo-UH1
                                  
    [Documentation]               Get Business Logo where Business logo is removed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200


JD-TC-Get_Business_Logo-UH2
                                  
    [Documentation]               Get Business Logo without uploading
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200


JD-TC-Get_Business_Logo-UH3
                                  
    [Documentation]               Get Business Logo without login

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              419
    Should Be Equal As Strings    ${resp.json()}      ${SESSION_EXPIRED}
