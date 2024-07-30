*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
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

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0

*** Test Cases ***

JD-TC-AutoInvoiceGeneration-1

    [Documentation]  Auto Invoice Generation for Catalog - Enable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${itemdata}=   FakerLibrary.words    	nb=6
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${unique_cnames}=   FakerLibrary.user name    
    ${resp}=   Create Sample Catalog    ${unique_cnames}    ${tz}    ${item_id1}   
    Set Suite Variable  ${catalod_id1}    ${resp}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${catalod_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Get Order Catalog    ${catalod_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    # ${resp}=   Get Service By Id  ${s_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AutoInvoiceGeneration-2

    [Documentation]  Auto Invoice Generation for Catalog - Disable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${catalod_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}


JD-TC-AutoInvoiceGeneration-UH1

    [Documentation]  Try to Enable Auto Invoice Generation for Catalog without jaldee finance enable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1} 
    Set Suite Variable  ${s_id1}

    ${resp}=   Get Service By Id  ${s_id1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${itemdata}=   FakerLibrary.words    	nb=6
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${unique_cnames}=   FakerLibrary.user name    
    ${resp}=   Create Sample Catalog    ${unique_cnames}    ${tz}    ${item_id1}    
    Set Suite Variable  ${catalod_id1}    ${resp}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${catalod_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${JALDEE_FINANCE_DISABLED}

JD-TC-AutoInvoiceGeneration-UH2

    [Documentation]  Item price is zero-then try to enable Auto Invoice Generation for Catalog .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${itemdata}=   FakerLibrary.words    	nb=6
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    # ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${order}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${unique_cnames}=   FakerLibrary.user name    
    ${resp}=   Create Sample Catalog    ${unique_cnames}    ${tz}    ${item_id1}      
    Set Test Variable  ${catalod_id1}    ${resp}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${catalod_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-AutoInvoiceGeneration-UH3

    [Documentation]  Auto Invoice Generation for catalog with invalid catalog id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${catalod_id1}=     Random Int   min=500   max=1000


    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
   Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_NOT_FOUND}"


JD-TC-AutoInvoiceGeneration-UH4

    [Documentation]  Auto Invoice Generation for catalog without login.


    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    
JD-TC-AutoInvoiceGeneration-UH5
    [Documentation]   Login as consumer and call auto invoice generation for catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-AutoInvoiceGeneration-UH6

    [Documentation]  Auto Invoice Generation for catalog with aother provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 

JD-TC-AutoInvoiceGeneration-UH7

    [Documentation]  Try to Enable Auto Invoice Generation for catalog without jaldee finance enable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${itemdata}=   FakerLibrary.words    	nb=6
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${unique_cnames}=   FakerLibrary.user name    
    ${resp}=   Create Sample Catalog    ${unique_cnames}    ${tz}    ${item_id1}    
    Set Test Variable  ${catalod_id1}    ${resp}

    ${resp}=  Auto Invoice Generation For Catalog   ${catalod_id1}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${JALDEE_FINANCE_DISABLED}





