*** Settings ***

Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        PARTNER
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderPartnerKeywords.robot

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${cc}   +91
${phone}     5555512345
${phone1}     5555512354
${phone2}     5555528954

*** Test Cases ***

JD-TC-Get_partner_Count-1
                                  
    [Documentation]               Get Partner Without passing filter

    ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

   ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    clear Customer  ${PUSERNAME26}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    # Set Suite Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Suite Variable    ${email}  ${fname}${lname}${C_Email}.${test_mail}
    Set Suite Variable    ${email2}  ${lname}${C_Email}.${test_mail}

    ${note}        FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}
    
    ${dealerfname}=  FakerLibrary.name
    Set Suite Variable    ${dealerfname}
    ${dealername}=  FakerLibrary.bs
    Set Suite Variable    ${dealername}
    ${dealerlname}=  FakerLibrary.last_name
    Set Suite Variable    ${dealerlname}

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Verify Phone Partner Creation    ${phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}       partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable   ${uid1}        ${resp.json()['uid']}
    Set Suite Variable   ${id1}        ${resp.json()['id']} 

    ${resp}=   Get Partner by UID    ${uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings   ${resp.json()["id"]}   ${id1}
    Should Be Equal As Strings   ${resp.json()["uid"]}   ${uid1}
    Set Suite Variable           ${refNo1}   ${resp.json()["referenceNo"]}
    Should Be Equal As Strings   ${resp.json()["partnerName"]}   ${firstName}
    Should Be Equal As Strings   ${resp.json()["partnerAliasName"]}   ${lastName}
    Should Be Equal As Strings   ${resp.json()["partnerMobile"]}   ${phone}

    ${resp}=    Get Partner Count-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    

JD-TC-Get_partner_Count-2
                                  
    [Documentation]               Get Partner with id

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  id-eq=${id1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-3
                                  
    [Documentation]               Get Partner with uid

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  uid-eq=${uid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-4
                                  
    [Documentation]               Get Partner with referenceNo

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  referenceNo-eq=${refNo1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-5
                                  
    [Documentation]               Get Partner with partnerName

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  partnerName-eq=${firstName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-6
                                  
    [Documentation]               Get Partner with  

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  partnerAliasName-eq=${lastName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-7
                                  
    [Documentation]               Get Partner with partnerMobile

    ${resp}=   ProviderLogin  ${PUSERNAME8}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter  partnerMobile-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Get_partner_Count-UH1
                                  
    [Documentation]               Get Partner without login

    ${resp}=    Get Partner Count-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-Get_partner_Count-UH2
                                  
    [Documentation]               Get Partner with another Provider Login

    ${resp}=   ProviderLogin  ${PUSERNAME7}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Partner Count-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200