*** Settings ***
Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         LOS Lead
Library            Collections
Library            String
Library            json
Library            FakerLibrary
Library            /ebs/TDD/db.py
Library            /ebs/TDD/excelfuncs.py
Resource           /ebs/TDD/ProviderKeywords.robot
Resource           /ebs/TDD/ConsumerKeywords.robot
Resource           /ebs/TDD/ProviderConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${losProduct}                    CDL
${aadhaar}                       555555555555
${pan}                           5555555555
${bankAccountNo}                 55555555555
${bankIfsc}                      55555555555

*** Test Cases ***

JD-TC-GetLeadCountByFilter-1

    [Documentation]             Get Lead Count By Filter

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id1}       ${resp.json()['id']}

    FOR    ${i}    IN RANGE  0  3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =   Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable  ${city}      ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${permanentState}     ${resp.json()[0]['PostOffice'][0]['State']}    
    Set Suite Variable  ${permanentDistrict}  ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${permanentPin}       ${resp.json()[0]['PostOffice'][0]['Pincode']}

    ${Sname}=    FakerLibrary.name
    Set Suite Variable      ${Sname}

    ${resp}=    Create Lead Status LOS  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${status_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Sname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

    ${Pname}=    FakerLibrary.name
    Set Suite Variable      ${Pname}

    ${resp}=    Create Lead Progress LOS  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${progress_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Pname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone}  555${PH_Number}
    ${requestedAmount}=     Random Int  min=30000  max=600000
    ${description}=         FakerLibrary.bs
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable      ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    Set Suite Variable      ${consumerLastName}
    ${dob}=    FakerLibrary.Date
    ${address}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}.${test_mail}   
    ${permanentAddress1}=   FakerLibrary.address
    ${permanentAddress2}=   FakerLibrary.address  
    ${nomineeName}=     FakerLibrary.first_name
    ${status}=  Create Dictionary  id=${status_id}  name=${Sname}
    ${progress}=  Create Dictionary  id=${progress_id}  name=${Pname}
    ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${losProduct}  ${requestedAmount}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${lead_uid}      ${resp.json()['uid']}

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${kycid}                ${resp.json()['consumerKyc']['id']}
    Set Suite Variable      ${referenceNo}          ${resp.json()['referenceNo']}
    Set Suite Variable      ${createdDate}          ${resp.json()['createdDate']}
    Set Suite Variable      ${consumerId}           ${resp.json()['consumerKyc']['consumerId']} 
    Set Suite Variable      ${internalProgress}     ${resp.json()['internalProgress']}
    Set Suite Variable      ${internalStatus}       ${resp.json()['internalStatus']}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone2}  555${PH_Number}
    ${requestedAmount2}=     Random Int  min=30000  max=600000
    ${description2}=         FakerLibrary.bs
    ${consumerFirstName2}=   FakerLibrary.first_name
    Set Suite Variable      ${consumerFirstName2}
    ${consumerLastName2}=    FakerLibrary.last_name  
    Set Suite Variable      ${consumerLastName2}
    ${dob2}=    FakerLibrary.Date
    ${address2}=  FakerLibrary.address
    ${gender2}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail2}  ${C_Email}${consumerPhone2}.${test_mail}   
    ${permanentAddress11}=   FakerLibrary.address
    ${permanentAddress22}=   FakerLibrary.address  
    ${nomineeName2}=     FakerLibrary.first_name
    ${status2}=  Create Dictionary  id=${status_id}  name=${Sname}
    ${progress2}=  Create Dictionary  id=${progress_id}  name=${Pname}
    ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName2}  consumerLastName=${consumerLastName2}  dob=${dob2}  gender=${gender2}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone2}  consumerEmail=${consumerEmail2}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress11}  permanentAddress2=${permanentAddress22}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName2}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${losProduct}  ${requestedAmount}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${lead_uid2}      ${resp.json()['uid']}

    ${resp}=    Get Lead LOS   ${lead_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${kycid2}                ${resp.json()['consumerKyc']['id']}
    Set Suite Variable      ${referenceNo2}          ${resp.json()['referenceNo']}
    Set Suite Variable      ${createdDate2}          ${resp.json()['createdDate']}
    Set Suite Variable      ${consumerId2}           ${resp.json()['consumerKyc']['consumerId']} 
    Set Suite Variable      ${internalProgress2}     ${resp.json()['internalProgress']}
    Set Suite Variable      ${internalStatus2}       ${resp.json()['internalStatus']}


    ${resp}=    Get Lead By Filter LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-2

    [Documentation]             Get Lead Count By Filter with uid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-3

    [Documentation]             Get Lead Count By Filter with referenceNo

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     referenceNo-eq=${referenceNo}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   referenceNo-eq=${referenceNo}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-4

    [Documentation]             Get Lead Count By Filter with losProduct

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     losProduct-eq=${losProduct}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   losProduct-eq=${losProduct}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-5

    [Documentation]             Get Lead Count By Filter with internalProgress

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     internalProgress-eq=${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   internalProgress-eq=${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-6

    [Documentation]             Get Lead Count By Filter with internalStatus

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-7

    [Documentation]             Get Lead Count By Filter with consumerId

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     consumerId-eq=${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   consumerId-eq=${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-8

    [Documentation]             Get Lead Count By Filter with consumerFirstName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     consumerFirstName-eq=${consumerFirstName}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   consumerFirstName-eq=${consumerFirstName}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-9

    [Documentation]             Get Lead Count By Filter with consumerLastName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS    consumerLastName-eq=${consumerLastName}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   consumerLastName-eq=${consumerLastName}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-10

    [Documentation]             Get Lead Count By Filter with createdDate

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     createdDate-eq=${createdDate}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   createdDate-eq=${createdDate}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-11

    [Documentation]             Get Lead Count By Filter with isConverted

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     isConverted-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   isConverted-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-12

    [Documentation]             Get Lead Count By Filter with isRejected

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     isRejected-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   isRejected-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-13

    [Documentation]             Get Lead Count By Filter - uid and reference

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid}  referenceNo-eq=${referenceNo}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid}  referenceNo-eq=${referenceNo}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-14

    [Documentation]             Get Lead Count By Filter - uid and losProduct

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid}  losProduct-eq=${losProduct}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid}  losProduct-eq=${losProduct}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-15

    [Documentation]             Get Lead Count By Filter - uid and internalProgress

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  internalProgress-eq=${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  internalProgress-eq=${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-16

    [Documentation]             Get Lead Count By Filter - uid and internalStatus

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}    

JD-TC-GetLeadCountByFilter-17

    [Documentation]             Get Lead Count By Filter - uid and consumerId

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  consumerId-eq=${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  consumerId-eq=${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-18

    [Documentation]             Get Lead Count By Filter - uid and consumerFirstName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}         


JD-TC-GetLeadCountByFilter-19

    [Documentation]             Get Lead Count By Filter - uid and consumerLastName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  consumerLastName-eq=${consumerLastName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  consumerLastName-eq=${consumerLastName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}           


JD-TC-GetLeadCountByFilter-20

    [Documentation]             Get Lead Count By Filter - uid and createdDate

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  createdDate-eq=${createdDate}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  createdDate-eq=${createdDate}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}          

JD-TC-GetLeadCountByFilter-21

    [Documentation]             Get Lead Count By Filter - uid and isConverted

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  isConverted-eq=${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  isConverted-eq=${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}                         

JD-TC-GetLeadCountByFilter-22

    [Documentation]             Get Lead Count By Filter - uid and isRejected

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     uid-eq=${lead_uid2}  isRejected-eq=${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   uid-eq=${lead_uid2}  isRejected-eq=${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len} 


JD-TC-GetLeadCountByFilter-23

    [Documentation]             Get Lead Count By Filter - both lead internalProgress

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     internalProgress-eq=${internalProgress2},${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   internalProgress-eq=${internalProgress2},${internalProgress}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}

JD-TC-GetLeadCountByFilter-24

    [Documentation]             Get Lead Count By Filter - uid and internalStatus

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     internalProgress-eq=${internalProgress}  internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   internalProgress-eq=${internalProgress}  internalStatus-eq=${internalStatus}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}    

JD-TC-GetLeadCountByFilter-25

    [Documentation]             Get Lead Count By Filter - both lead consumerFirstName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     consumerFirstName-eq=${consumerFirstName},${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   consumerFirstName-eq=${consumerFirstName},${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-26

    [Documentation]             Get Lead Count By Filter - consumerLastName and consumerFirstName

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS     consumerLastName-eq=${consumerLastName}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Set Test Variable      ${len}

    ${resp}=    Get Lead Count By Filter LOS   consumerLastName-eq=${consumerLastName}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${len}


JD-TC-GetLeadCountByFilter-UH1

    [Documentation]             Get Lead Count By Filter - without login

    ${resp}=    Get Lead Count By Filter LOS   consumerLastName-eq=${consumerLastName}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}


JD-TC-GetLeadCountByFilter-UH2

    [Documentation]             Get Lead Count By Filter - with Provider consumer login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${provider_name}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

    FOR    ${i}    IN RANGE  0  3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =   Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable  ${city}      ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${permanentState}     ${resp.json()[0]['PostOffice'][0]['State']}    
    Set Test Variable  ${permanentDistrict}  ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${permanentPin}       ${resp.json()[0]['PostOffice'][0]['Pincode']}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone}  555${PH_Number}

    ${resp1}=  AddCustomer  ${consumerPhone}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}=    Get Lead Count By Filter LOS   consumerLastName-eq=${consumerLastName}  consumerFirstName-eq=${consumerFirstName2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}
