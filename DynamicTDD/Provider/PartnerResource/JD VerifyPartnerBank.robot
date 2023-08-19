*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PARTNER
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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

*** Test Cases ***

JD-TC-Verify Partner Bank-1
                                  
    [Documentation]              Verify Partner Bank

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${firstName}=    FakerLibrary.firstName
    Set Suite Variable    ${firstName}
    ${lastName}=    FakerLibrary.lastName
    Set Suite Variable    ${lastName}
    Set Suite Variable  ${email}  ${firstName}${C_Email}.ynwtest@netvarth.com

    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

    # .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pin}  ${resp.json()['pinCode']}
    Set Suite Variable  ${address1}  ${resp.json()['address']}
    Set Suite Variable  ${longitude}  ${resp.json()['longitude']}
    Set Suite Variable  ${lattitude}  ${resp.json()['lattitude']}
    Set Suite Variable  ${googleMapUrl}  ${resp.json()['googleMapUrl']}
    Set Suite Variable  ${googleMapLocation}    ${resp.json()['place']}

    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state} 

   ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END 
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    # ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=${bool[0]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype           ${account_id}
    ${resp}=  categorytype          ${account_id}
    ${resp}=  tasktype              ${account_id}
    ${resp}=  loanStatus            ${account_id}
    ${resp}=  loanProducttype       ${account_id}
    ${resp}=  LoanProductCategory   ${account_id}
    ${resp}=  loanProducts          ${account_id}
    ${resp}=  loanScheme            ${account_id}

    ${resp}=    Get Partner Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone}  555${PH_Number}

    ${dealerfname}=  FakerLibrary.name
    Set Suite Variable    ${dealerfname}
    ${dealername}=  FakerLibrary.bs
    Set Suite Variable    ${dealername}
    ${dealerlname}=  FakerLibrary.last_name
    Set Suite Variable    ${dealerlname}

    ${resp}=  Generate Phone Partner Creation    ${P_phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${P_phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}     ${Puid1}    ${LoanAction[0]}    ${Pid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Verify Partner Bank-UH1
                                  
    [Documentation]              Verify Partner Bank where pid is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${empty}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Verify Partner Bank-UH2
                                  
    [Documentation]              Verify Partner Bank where pid is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_pid}    FakerLibrary.Random Number

    ${resp}    Verify Partner Bank    ${inv_pid}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Verify Partner Bank-UH3
                                  
    [Documentation]              Verify Partner Bank where uid is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}     ${empty}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${PARTNER_UID_REQ}



JD-TC-Verify Partner Bank-UH4
                                  
    [Documentation]              Verify Partner Bank where uid is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_Puid1}    FakerLibrary.Random Number

    ${resp}    Verify Partner Bank    ${Pid1}     ${inv_Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PARTNER_ID}


JD-TC-Verify Partner Bank-UH5
                                  
    [Documentation]              Verify Partner Bank where bankname is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${empty} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Verify Partner Bank-UH6
                                  
    [Documentation]              Verify Partner Bank where bank account number is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${empty}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${ACCOUNR_NUMBER_REQ}


JD-TC-Verify Partner Bank-UH7
                                  
    [Documentation]              Verify Partner Bank where bank account number is invalid

    # which account number or ifsc code we are using while verifing that will be updated as partner ac num and ifsc

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_accno}    FakerLibrary.Random Number

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${inv_accno}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    ${NO_BANK_DETAILS_FOUND}

    ${resp}    Get Partner by UID    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
JD-TC-Verify Partner Bank-UH8
                                  
    [Documentation]              Verify Partner Bank where bank ifsc is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_ifsc}    FakerLibrary.Random Number

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${bankAccountNo}    ${inv_ifsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    ${NO_BANK_DETAILS_FOUND}

    ${resp}    Get Partner by UID    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Verify Partner Bank-UH9
                                  
    [Documentation]              Verify Partner Bank with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}


JD-TC-Verify Partner Bank-UH10
                                  
    [Documentation]              Verify Partner Bank without login

    ${resp}    Verify Partner Bank    ${Pid1}     ${Puid1}    ${bankAccountNo}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}