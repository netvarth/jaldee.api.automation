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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx
${order}    0
${fileSizes}  0.00458
${inv_pin}    123

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

*** Test Cases ***

JD-TC-Update Partner Details-1
                                  
    [Documentation]              Update Partner Details

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

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

    reset_user_metric  ${account_id}

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
    Set Suite Variable  ${email}  ${firstName}${C_Email}.${test_mail}

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
    ${address2}    FakerLibrary.Street name
    Set Suite Variable    ${address2}
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
    Set Suite Variable    ${branch}

    ${resp}=  Verify Phone Partner Creation    ${P_phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}        partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${partnerName}                FakerLibrary.name
    Set Suite Variable    ${partnerName}
    ${partnerAliasName}           FakerLibrary.name
    Set Suite Variable    ${partnerAliasName}
    ${description}                FakerLibrary.sentence
    Set Suite Variable    ${description}
    ${aadhaar}    Random Number 	digits=5 
    ${aadhaar}=    Evaluate    f'{${aadhaar}:0>7d}'
    Log  ${aadhaar}
    Set Suite Variable  ${aadhaar}  55555${aadhaar}
    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    Set Suite Variable    ${partnerCity}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

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

    ${resp}=  db.getType   ${jpgfile2}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary       ${resp}    ${jpgfile2}
    Set Suite Variable    ${fileType4}
    ${caption4}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption4}

    ${resp}=  db.getType   ${gif}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${gif}
    Set Suite Variable    ${fileType5}
    ${caption5}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption5}

    ${resp}=  db.getType   ${xlsx}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${xlsx}
    Set Suite Variable    ${fileType6}
    ${caption6}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption6}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}
    Set Suite Variable    ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pngfile}  fileSize=${fileSizes}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}
    Set Suite Variable    ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${jpgfile}  fileSize=${fileSizes}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}
    Set Suite Variable    ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${jpgfile2}  fileSize=${fileSizes}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}
    Set Suite Variable    ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${gif}  fileSize=${fileSizes}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}
    Set Suite Variable    ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${xlsx}  fileSize=${fileSizes}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}
    Set Suite Variable    ${storeAttachments}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 


JD-TC-Update Partner Details-UH1
                                   
    [Documentation]              Update Partner Details with invalid partner uid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_puid}    FakerLibrary.Random Number

    ${resp}=    Partner Details    ${inv_puid}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PARTNER_ID}


JD-TC-Update Partner Details-UH2
                                  
    [Documentation]              Update Partner Details where uid is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${empty}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500


JD-TC-Update Partner Details-UH3
                                  
    [Documentation]              Update Partner Details where partner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${empty}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${PARTNER_NAME_REQUIRED}


JD-TC-Update Partner Details-UH4
                                  
    [Documentation]              Update Partner Details where partner phone is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${empty}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${MOBILE_NO_REQUIRED}


JD-TC-Update Partner Details-UH5
                                  
    [Documentation]              Update Partner Details where partner phone is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone2}  555${PH_Number}

    ${dealerfname}=  FakerLibrary.name
    Set Suite Variable    ${dealerfname}
    ${dealername}=  FakerLibrary.bs
    Set Suite Variable    ${dealername}
    ${dealerlname}=  FakerLibrary.last_name
    Set Suite Variable    ${dealerlname}

    ${resp}=  Generate Phone Partner Creation    ${P_phone2}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}
    Set Suite Variable    ${branch}

    ${resp}=  Verify Phone Partner Creation    ${P_phone2}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}        partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid2}  ${resp.json()['uid']} 

    ${inv_num}      FakerLibrary.Random Number

    ${resp}=    Partner Details    ${Puid2}    ${partnerName}    ${inv_num}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    422
    
    ${resp}=    Get Partner by UID    ${Puid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()["partnerMobile"]}    ${P_phone2}


JD-TC-Update Partner Details-UH6
                                  
    [Documentation]              Update Partner Details where partner email is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid2}    ${partnerName}    ${P_phone}    ${empty}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${Puid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update Partner Details-UH7
                                  
    [Documentation]              Update Partner Details where partner description is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid2}    ${partnerName}    ${P_phone}    ${email}    ${empty}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Update Partner Details-UH8
                                  
    [Documentation]              Update Partner Details where partner type id is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${empty}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${Puid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update Partner Details-UH9
                                  
    [Documentation]              Update Partner Details where partner category id is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${empty}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${Puid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update Partner Details-UH11
                                  
    [Documentation]              Update Partner Details where partner address is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${empty}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

    ${resp}=    Get Partner by UID    ${Puid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update Partner Details-UH12
                                  
    [Documentation]              Update Partner Details where partner address 2 is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${empty}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH13
                                  
    [Documentation]              Update Partner Details where partner pin is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${empty}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH14
                                  
    [Documentation]              Update Partner Details where partner city is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${empty}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH15
                                  
    [Documentation]              Update Partner Details where partner district is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${empty}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH16
                                  
    [Documentation]              Update Partner Details where partner state is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone3}  555${PH_Number}

    ${dealerfname}=  FakerLibrary.name
    Set Suite Variable    ${dealerfname}
    ${dealername}=  FakerLibrary.bs
    Set Suite Variable    ${dealername}
    ${dealerlname}=  FakerLibrary.last_name
    Set Suite Variable    ${dealerlname}

    ${resp}=  Generate Phone Partner Creation    ${P_phone3}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}
    Set Suite Variable    ${branch}

    ${resp}=  Verify Phone Partner Creation    ${P_phone3}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}        partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid3}  ${resp.json()['uid']}

    ${resp}=    Partner Details    ${Puid3}    ${partnerName}    ${P_phone3}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${empty}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${KYC_STATE_REQUIRED}
    
    ${resp}=    Get Partner by UID    ${Puid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Update Partner Details-UH17
                                  
    [Documentation]              Update Partner Details where partner aadhaar is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${empty}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH18
                                  
    [Documentation]              Update Partner Details where partner pan is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${empty}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH19
                                  
    [Documentation]              Update Partner Details where pin is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${inv_pin}    FakerLibrary.Random Number

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${inv_pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PIN}


JD-TC-Update Partner Details-UH20
                                  
    [Documentation]              Update Partner Details where partner aadhar is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_aadhar}    FakerLibrary.Random Number

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${inv_aadhar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH21
                                  
    [Documentation]              Update Partner Details where gst is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${empty}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH22
                                  
    [Documentation]              Update Partner Details where gst is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${branch2}=      Create Dictionary   id=${empty}
    Set Suite Variable    ${branch2}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH23
                                  
    [Documentation]              Update Partner Details where partner alias name is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${branch2}=      Create Dictionary   id=${empty}
    Set Suite Variable    ${branch2}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${empty}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH24
                                  
    [Documentation]              Update Partner Details where aadhar attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH25
                                  
    [Documentation]              Update Partner Details where aadhar attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH26
                                  
    [Documentation]              Update Partner Details where aadhar attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH27
                                  
    [Documentation]              Update Partner Details where aadhar attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH28
                                  
    [Documentation]              Update Partner Details where aadhar attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH29
                                  
    [Documentation]              Update Partner Details where aadhar attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH30
                                  
    [Documentation]              Update Partner Details where aadhar attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH31
                                  
    [Documentation]              Update Partner Details where aadhar attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${aadhaarAttachments1}=    Create List  ${aadhaarAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments1}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Update Partner Details-UH32
                                  
    [Documentation]              Update Partner Details where pan attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH33
                                  
    [Documentation]              Update Partner Details where pan attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH34
                                  
    [Documentation]              Update Partner Details where pan attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH35
                                  
    [Documentation]              Update Partner Details where pan attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH36
                                  
    [Documentation]              Update Partner Details where pan attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH37
                                  
    [Documentation]              Update Partner Details where pan attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH38
                                  
    [Documentation]              Update Partner Details where pan attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH39
                                  
    [Documentation]              Update Partner Details where pan attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${panAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${panAttachments1}=    Create List  ${panAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments1}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH40
                                  
    [Documentation]              Update Partner Details where gst attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH41
                                  
    [Documentation]              Update Partner Details where gst attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH42
                                  
    [Documentation]              Update Partner Details where gst attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH43
                                  
    [Documentation]              Update Partner Details where gst attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH44
                                  
    [Documentation]              Update Partner Details where gst attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH45
                                  
    [Documentation]              Update Partner Details where gst attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH46
                                  
    [Documentation]              Update Partner Details where gst attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH47
                                  
    [Documentation]              Update Partner Details where gst attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gstAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${gstAttachments1}=    Create List  ${gstAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments1}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH48
                                  
    [Documentation]              Update Partner Details where license attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH49
                                  
    [Documentation]              Update Partner Details where licence attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH50
                                  
    [Documentation]              Update Partner Details where license attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH51
                                  
    [Documentation]              Update Partner Details where license attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH52
                                  
    [Documentation]              Update Partner Details where license attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH53
                                  
    [Documentation]              Update Partner Details where license attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH54
                                  
    [Documentation]              Update Partner Details where license attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH55
                                  
    [Documentation]              Update Partner Details where License attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licenceAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${licenceAttachments1}=    Create List  ${licenceAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments1}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH56
                                  
    [Documentation]              Update Partner Details where partner attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH57
                                  
    [Documentation]              Update Partner Details where partner attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH58
                                  
    [Documentation]              Update Partner Details where partner attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH59
                                  
    [Documentation]              Update Partner Details where partner attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH60
                                  
    [Documentation]              Update Partner Details where partner attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH61
                                  
    [Documentation]              Update Partner Details where partner attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH62
                                  
    [Documentation]              Update Partner Details where partner attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH63
                                  
    [Documentation]              Update Partner Details where partner attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${partnerAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${partnerAttachments1}=    Create List  ${partnerAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments1}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH64
                                  
    [Documentation]              Update Partner Details where store attachment action is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[3]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH65
                                  
    [Documentation]              Update Partner Details where store attachment owner is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH66
                                  
    [Documentation]              Update Partner Details where store attachment owner is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_owner}    FakerLibrary.Random Number

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${inv_owner}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH67
                                  
    [Documentation]              Update Partner Details where store attachment filename is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${empty}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH68
                                  
    [Documentation]              Update Partner Details where store attachment filesize is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FILE_SIZE_ERROR}


JD-TC-Update Partner Details-UH69
                                  
    [Documentation]              Update Partner Details where store attachment caption is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${empty}  fileType=${fileType3}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH70
                                  
    [Documentation]              Update Partner Details where store attachment filetype is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${empty}  order=${order}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC-Update Partner Details-UH71
                                  
    [Documentation]              Update Partner Details where store attachment order is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSizes}  caption=${caption3}  fileType=${fileType3}  order=${empty}
    ${storeAttachments1}=    Create List  ${storeAttachments1}

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Update Partner Details-UH72
                                  
    [Documentation]              Update Partner Details without login

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-Update Partner Details-UH73
                                  
    [Documentation]              Update Partner Details with another user login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${typeid}    ${categoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}
    
